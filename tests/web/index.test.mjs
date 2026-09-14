import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const scriptUrl = new URL('../../src/web/view/static/index.js', import.meta.url);
const source = await readFile(scriptUrl, 'utf8');
const moduleUrl = `data:text/javascript;base64,${Buffer.from(source).toString('base64')}`;
const webModule = await import(moduleUrl);

const successResponse = (overrides = {}) => ({
    success: true,
    target: '1c',
    code: 'Код',
    errors: [],
    warnings: [],
    ...overrides
});

function eventTarget(extra = {}) {
    const listeners = new Map();
    return {
        addEventListener: (name, listener) => listeners.set(name, listener),
        listeners,
        ...extra
    };
}

function messageContainer() {
    return {
        hidden: true,
        nodes: [],
        replaceChildren() { this.nodes = []; },
        append(node) { this.nodes.push(node); }
    };
}

function createElements() {
    const attributes = new Map([['aria-busy', 'false']]);
    const control = (extra = {}) => ({
        disabled: false,
        toggleAttribute(name, enabled) { this[name] = enabled; },
        ...eventTarget(extra)
    });
    const command = control({
        value: 'curl https://example.com',
        checkValidity: () => true,
        setAttribute(name, value) { this[name] = value; },
        removeAttribute(name) { delete this[name]; },
        focus() { this.focused = true; }
    });
    const convertButton = control();
    const target = control({ checked: true, value: 'connector' });
    const locale = control({
        value: 'en',
        getAttribute: (name) => name === 'aria-pressed' ? 'true' : null,
        setAttribute() {}
    });
    const jsonCheckbox = control({ checked: true });
    return {
        form: eventTarget({ checkValidity: () => true }),
        command,
        convertButton,
        generatorOptions: [target],
        localeButtons: [locale],
        jsonCheckbox,
        errors: messageContainer(),
        warnings: messageContainer(),
        output: {
            getAttribute: (name) => attributes.get(name),
            setAttribute: (name, value) => attributes.set(name, value)
        },
        requestControls: [command, convertButton, target, jsonCheckbox, locale],
        requestPending: false
    };
}

const documentRef = {
    createElement: (name) => ({ name }),
    createTextNode: (text) => ({ text }),
    defaultView: null,
    addEventListener() {}
};

test('собирает полное тело запроса из формы', () => {
    const payload = webModule.collectConversionRequest(createElements());
    assert.deepEqual(payload, {
        command: 'curl https://example.com',
        target: 'connector',
        locale: 'en',
        generatorOptions: { deserializeJsonResponse: true }
    });
});

test('отклоняет пустую команду до отправки запроса', async () => {
    const elements = createElements();
    elements.form.checkValidity = () => false;
    let requestCount = 0;

    const result = await webModule.submitConversion({
        elements,
        requestConversion: async () => {
            requestCount += 1;
            return successResponse();
        },
        showOutput() {},
        documentRef
    });

    assert.equal(result, false);
    assert.equal(requestCount, 0);
    assert.equal(elements.command['aria-invalid'], 'true');
    assert.equal(elements.command.focused, true);
    assert.deepEqual(elements.errors.nodes, [{ text: 'Введите команду curl' }]);
});

test('отправляет точный запрос на API v2', async () => {
    let actualUrl;
    let actualOptions;
    const payload = { command: 'curl example.com' };
    const result = await webModule.requestConversion(async (url, options) => {
        actualUrl = url;
        actualOptions = options;
        return { json: async () => successResponse() };
    }, payload);

    assert.equal(actualUrl, '/api/v2/convert');
    assert.deepEqual(actualOptions, {
        method: 'POST',
        headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    });
    assert.deepEqual(result, successResponse());
});

test('принимает договорную оболочку ошибочного HTTP-ответа', async () => {
    const expected = successResponse({
        success: false,
        code: '',
        errors: [{ code: 'data.invalid', message: 'Ошибка', position: null }]
    });
    const result = await webModule.requestConversion(async () => ({
        ok: false,
        status: 400,
        json: async () => expected
    }), {});
    assert.deepEqual(result, expected);
});

test('показывает место ошибки в снимке отправленной команды', async () => {
    const elements = createElements();
    elements.command.value = 'wget https://example.com';
    let completeRequest;

    const conversion = webModule.submitConversion({
        elements,
        requestConversion: () => new Promise((resolve) => { completeRequest = resolve; }),
        showOutput() {},
        documentRef
    });
    elements.command.value = 'curl https://changed.example';
    completeRequest(successResponse({
        success: false,
        code: '',
        errors: [{
            code: 'curlone.command.curl_required',
            message: 'В начале команды ожидается curl',
            position: 1
        }]
    }));

    assert.equal(await conversion, false);
    assert.deepEqual(elements.errors.nodes, [{
        text: 'В начале команды ожидается curl\nwget https://example.com\n^^^^'
    }]);
});

test('сохраняет всю многострочную команду при выводе места ошибки', () => {
    const elements = createElements();
    const error = { code: 'error', message: 'Ошибка', position: 19 };

    webModule.renderMessages([error], [], elements, documentRef, 'curl example1.com\ncurr example2.com');

    assert.deepEqual(elements.errors.nodes, [{
        text: 'Ошибка\ncurl example1.com\ncurr example2.com\n^^^^'
    }]);
});

test('отклоняет ответ неверной формы', async () => {
    await assert.rejects(
        webModule.requestConversion(async () => ({ json: async () => ({ result: 'старый контракт' }) }), {}),
        TypeError
    );
});

test('выводит код, ошибки и предупреждения безопасными текстовыми узлами', async () => {
    const elements = createElements();
    let shownOutput;
    const result = await webModule.submitConversion({
        elements,
        requestConversion: async () => successResponse({
            warnings: [{
                code: 'warning', message: '<img src=x onerror=alert(1)>',
                capability: null, option: null, position: null, target: 'connector'
            }]
        }),
        showOutput: (value) => { shownOutput = value; },
        documentRef
    });

    assert.equal(result, true);
    assert.equal(shownOutput, 'Код');
    assert.deepEqual(elements.warnings.nodes, [{ text: '<img src=x onerror=alert(1)>' }]);
    assert.equal(elements.requestPending, false);
});

test('схлопывает одинаковые предупреждения с разными позициями при отображении', () => {
    const elements = createElements();
    const warning = {
        code: 'curlone.generator.capability_unsupported',
        message: 'Повторные попытки запроса не будут выполнены.',
        capability: 'retry.count',
        option: '--retry',
        position: 2,
        target: 'connector'
    };
    const warnings = [warning, { ...warning, position: 5 }];

    webModule.renderMessages([], warnings, elements, documentRef);

    assert.deepEqual(elements.warnings.nodes, [{ text: warning.message }]);
    assert.equal(warnings.length, 2);
});

test('сохраняет различающиеся предупреждения при отображении', () => {
    const elements = createElements();
    const warning = {
        code: 'curlone.generator.capability_unsupported',
        message: 'Повторные попытки запроса не будут выполнены.',
        capability: 'retry.count',
        option: '--retry',
        position: 2,
        target: 'connector'
    };

    webModule.renderMessages([], [warning, { ...warning, target: '1c' }], elements, documentRef);

    assert.deepEqual(elements.warnings.nodes, [
        { text: warning.message },
        { name: 'br' },
        { text: warning.message }
    ]);
});

test('показывает общую ошибку при сетевом сбое', async () => {
    const elements = createElements();
    let shownOutput = 'старый код';
    const result = await webModule.submitConversion({
        elements,
        requestConversion: async () => { throw new Error('secret'); },
        showOutput: (value) => { shownOutput = value; },
        documentRef
    });

    assert.equal(result, false);
    assert.equal(shownOutput, '');
    assert.deepEqual(elements.errors.nodes, [{ text: 'Не удалось выполнить запрос' }]);
    assert.equal(elements.requestPending, false);
});

test('блокирует повторную отправку до завершения первой', async () => {
    const elements = createElements();
    let resolveRequest;
    let requestCount = 0;
    const sendRequest = () => {
        requestCount += 1;
        return new Promise((resolve) => { resolveRequest = resolve; });
    };
    const options = {
        elements,
        requestConversion: sendRequest,
        showOutput() {},
        documentRef
    };

    const first = webModule.submitConversion(options);
    const second = await webModule.submitConversion(options);
    assert.equal(second, false);
    assert.equal(requestCount, 1);
    assert.equal(elements.convertButton.disabled, true);

    resolveRequest(successResponse());
    assert.equal(await first, true);
    assert.equal(elements.convertButton.disabled, false);
});

test('включает форму после загрузки подсветки', async () => {
    const elements = createElements();
    const highlighter = {};
    const result = await webModule.initializeApplication({
        elements,
        loadHighlighter: async () => highlighter,
        showCriticalError() {}
    });

    assert.equal(result, highlighter);
    assert.equal(elements.requestControls.every((control) => control.disabled === false), true);
    assert.equal(elements.output.getAttribute('aria-busy'), 'false');
});

test('оставляет форму заблокированной при ошибке загрузки подсветки', async () => {
    const elements = createElements();
    let shownError;
    const result = await webModule.initializeApplication({
        elements,
        loadHighlighter: async () => { throw new Error('secret'); },
        showCriticalError: (message) => { shownError = message; }
    });

    assert.equal(result, null);
    assert.equal(shownError, 'Не удалось инициализировать подсветку синтаксиса');
    assert.equal(elements.requestControls.every((control) => control.disabled === true), true);
    assert.equal(elements.output.getAttribute('aria-busy'), 'false');
});

test('обрабатывает отправку формы и сочетание Ctrl+Enter', () => {
    const elements = createElements();
    const currentDocument = eventTarget();
    let conversionCount = 0;
    let submitCount = 0;
    let submitPrevented = false;
    let shortcutPrevented = false;
    elements.form.requestSubmit = () => { submitCount += 1; };
    webModule.bindConversionForm({
        elements,
        convert: () => { conversionCount += 1; },
        documentRef: currentDocument
    });

    elements.form.listeners.get('submit')({ preventDefault: () => { submitPrevented = true; } });
    currentDocument.listeners.get('keydown')({
        key: 'Enter',
        ctrlKey: true,
        preventDefault: () => { shortcutPrevented = true; }
    });

    assert.equal(conversionCount, 1);
    assert.equal(submitPrevented, true);
    assert.equal(submitCount, 1);
    assert.equal(shortcutPrevented, true);
});

test('не отправляет форму по Ctrl+Enter во время композиции текста', () => {
    const elements = createElements();
    const currentDocument = eventTarget();
    let submitCount = 0;
    elements.form.requestSubmit = () => { submitCount += 1; };
    webModule.bindConversionForm({
        elements,
        convert: () => {},
        documentRef: currentDocument
    });

    currentDocument.listeners.get('keydown')({
        key: 'Enter',
        ctrlKey: true,
        isComposing: true,
        preventDefault: () => {}
    });

    assert.equal(submitCount, 0);
});

test('переключает язык генерируемого кода', () => {
    const elements = createElements();
    let conversionCount = 0;
    const localeButton = (value, pressed) => {
        const attributes = new Map([['aria-pressed', String(pressed)]]);
        return eventTarget({
            value,
            getAttribute: (name) => attributes.get(name),
            setAttribute: (name, valueToSet) => attributes.set(name, valueToSet)
        });
    };
    const russian = localeButton('ru', true);
    const english = localeButton('en', false);
    elements.localeButtons = [russian, english];
    webModule.bindConversionForm({
        elements,
        convert: () => { conversionCount += 1; },
        documentRef: eventTarget()
    });

    english.listeners.get('click')();

    assert.equal(russian.getAttribute('aria-pressed'), 'false');
    assert.equal(english.getAttribute('aria-pressed'), 'true');
    assert.equal(webModule.collectConversionRequest(elements).locale, 'en');
    assert.equal(conversionCount, 1);
});

test('не конвертирует при выборе уже активного языка', () => {
    const elements = createElements();
    let conversionCount = 0;
    webModule.bindConversionForm({
        elements,
        convert: () => { conversionCount += 1; },
        documentRef: eventTarget()
    });

    elements.localeButtons[0].listeners.get('click')();

    assert.equal(conversionCount, 0);
});

test('автоматически конвертирует при изменении цели', () => {
    const elements = createElements();
    let conversionCount = 0;
    webModule.bindConversionForm({
        elements,
        convert: () => { conversionCount += 1; },
        documentRef: eventTarget()
    });

    elements.generatorOptions[0].listeners.get('change')?.();

    assert.equal(conversionCount, 1);
});

test('автоматически конвертирует при изменении чтения JSON', () => {
    const elements = createElements();
    let conversionCount = 0;
    webModule.bindConversionForm({
        elements,
        convert: () => { conversionCount += 1; },
        documentRef: eventTarget()
    });

    elements.jsonCheckbox.listeners.get('change')?.();

    assert.equal(conversionCount, 1);
});

test('не конвертирует автоматически при невалидной форме', () => {
    const elements = createElements();
    elements.form.checkValidity = () => false;
    let conversionCount = 0;
    webModule.bindConversionForm({
        elements,
        convert: () => { conversionCount += 1; },
        documentRef: eventTarget()
    });

    elements.jsonCheckbox.listeners.get('change')();

    assert.equal(conversionCount, 0);
    assert.equal(elements.command['aria-invalid'], undefined);
    assert.deepEqual(elements.errors.nodes, []);
});

test('объединяет изменения настроек во время конвертации в один повторный запрос', async () => {
    const elements = createElements();
    let completeFirstConversion;
    let conversionCount = 0;
    const convert = () => {
        conversionCount += 1;
        if (conversionCount === 1) {
            return new Promise((resolve) => { completeFirstConversion = resolve; });
        }
        return Promise.resolve();
    };
    webModule.bindConversionForm({ elements, convert, documentRef: eventTarget() });

    elements.localeButtons[0].listeners.get('click')();
    elements.generatorOptions[0].listeners.get('change')();
    elements.jsonCheckbox.listeners.get('change')();

    assert.equal(conversionCount, 1);
    completeFirstConversion();
    await new Promise((resolve) => setImmediate(resolve));
    assert.equal(conversionCount, 2);
});

test('копирует сформированный код в буфер обмена', async () => {
    const elements = createElements();
    let copiedText;

    const result = await webModule.copyOutput({
        clipboard: { writeText: async (text) => { copiedText = text; } },
        outputText: 'Код',
        elements,
        documentRef
    });

    assert.equal(result, true);
    assert.equal(copiedText, 'Код');
    assert.equal(elements.errors.hidden, true);
});

test('показывает ошибку при сбое копирования', async () => {
    const elements = createElements();

    const result = await webModule.copyOutput({
        clipboard: { writeText: async () => { throw new Error('secret'); } },
        outputText: 'Код',
        elements,
        documentRef
    });

    assert.equal(result, false);
    assert.deepEqual(elements.errors.nodes, [{ text: 'Не удалось скопировать код' }]);
});
