const REQUEST_ERROR_MESSAGE = 'Не удалось выполнить запрос';
const HIGHLIGHTER_ERROR_MESSAGE = 'Не удалось инициализировать подсветку синтаксиса';
const REQUIRED_COMMAND_MESSAGE = 'Введите команду curl';
const COPY_ERROR_MESSAGE = 'Не удалось скопировать код';

export function setBusy(elements, isBusy) {
    for (const control of elements.requestControls) {
        control.disabled = isBusy;
    }
    elements.output.setAttribute('aria-busy', String(isBusy));
}

export function setRequestPending(elements, isPending) {
    elements.requestPending = isPending;
    elements.convertButton.disabled = isPending;
    for (const control of elements.requestControls) {
        control.toggleAttribute('inert', isPending);
    }
    elements.output.setAttribute('aria-busy', String(isPending));
}

export function setLocale(elements, locale) {
    for (const button of elements.localeButtons) {
        button.setAttribute('aria-pressed', String(button.value === locale));
    }
}

function appendMessages(container, records, documentRef, formatMessage = (record) => record.message) {
    container.replaceChildren();
    records.forEach((record, index) => {
        if (index > 0) {
            container.append(documentRef.createElement('br'));
        }
        container.append(documentRef.createTextNode(formatMessage(record)));
    });
    container.hidden = records.length === 0;
}

function formatErrorMessage(record, command) {
    if (!Number.isInteger(record.position) || record.position < 1 || record.position > command.length) {
        return record.message;
    }

    const offset = record.position - 1;
    const lineStart = command.lastIndexOf('\n', offset - 1) + 1;
    const nextLineBreak = command.indexOf('\n', offset);
    const lineEnd = nextLineBreak === -1 ? command.length : nextLineBreak;
    const line = command.slice(lineStart, lineEnd).replace(/\r$/, '');
    const column = offset - lineStart;
    const token = line.slice(column).match(/^\S+/)?.[0] ?? '';
    const marker = line.slice(0, column).replace(/[^\t]/g, ' ') + '^'.repeat(Math.max(token.length, 1));
    const commandWithMarker = command.slice(0, lineStart) + line + `\n${marker}` + command.slice(lineEnd);
    return `${record.message}\n${commandWithMarker}`;
}

function uniqueWarnings(warnings) {
    const fields = ['code', 'message', 'capability', 'option', 'target'];
    const seen = new Set();
    return warnings.filter((warning) => {
        const key = JSON.stringify(fields.map((field) => warning[field]));
        if (seen.has(key)) {
            return false;
        }
        seen.add(key);
        return true;
    });
}

export function renderMessages(errors, warnings, elements, documentRef, command = '') {
    appendMessages(elements.errors, errors, documentRef, (record) => formatErrorMessage(record, command));
    appendMessages(elements.warnings, uniqueWarnings(warnings), documentRef);
}

export async function copyOutput({ clipboard, outputText, elements, documentRef }) {
    try {
        await clipboard.writeText(outputText);
        return true;
    } catch (error) {
        renderMessages([{ message: COPY_ERROR_MESSAGE }], [], elements, documentRef);
        return false;
    }
}

function revealErrors(elements, documentRef) {
    const windowRef = documentRef.defaultView;
    const isMobile = windowRef?.matchMedia?.('(max-width: 36rem)').matches ?? false;
    if (!elements.errors.hidden && isMobile && typeof elements.errors.scrollIntoView === 'function') {
        elements.errors.scrollIntoView({ block: 'nearest' });
    }
}

function selectedTarget(elements) {
    return elements.generatorOptions.find((option) => option.checked)?.value ?? '1c';
}

function selectedLocale(elements) {
    return elements.localeButtons.find((button) => button.getAttribute('aria-pressed') === 'true')?.value ?? 'ru';
}

export function collectConversionRequest(elements) {
    return {
        command: elements.command.value,
        target: selectedTarget(elements),
        locale: selectedLocale(elements),
        generatorOptions: {
            responseDeserializationFormat: elements.jsonCheckbox.checked ? 'json' : undefined
        }
    };
}

function isErrorRecord(value) {
    return value !== null && typeof value === 'object'
        && typeof value.code === 'string' && typeof value.message === 'string'
        && (value.position === null || Number.isInteger(value.position) && value.position >= 1);
}

function isWarningRecord(value) {
    return isErrorRecord(value)
        && ['capability', 'option', 'position', 'target'].every((name) => name in value);
}

export function isConversionResponse(value) {
    return value !== null && typeof value === 'object'
        && typeof value.success === 'boolean'
        && typeof value.target === 'string'
        && typeof value.code === 'string'
        && Array.isArray(value.errors) && value.errors.every(isErrorRecord)
        && Array.isArray(value.warnings) && value.warnings.every(isWarningRecord);
}

export async function requestConversion(fetchRef, payload) {
    const response = await fetchRef('/api/v2/convert', {
        method: 'POST',
        headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    });
    const result = await response.json();
    if (!isConversionResponse(result)) {
        throw new TypeError('Invalid conversion response');
    }
    return result;
}

export async function submitConversion({
    elements,
    form = elements.form,
    requestConversion: sendRequest,
    showOutput,
    documentRef
}) {
    if (!form.checkValidity()) {
        elements.command.setAttribute('aria-invalid', 'true');
        renderMessages([{ message: REQUIRED_COMMAND_MESSAGE }], [], elements, documentRef);
        elements.command.focus();
        revealErrors(elements, documentRef);
        return false;
    }
    if (elements.requestPending) {
        return false;
    }

    elements.command.removeAttribute('aria-invalid');
    renderMessages([], [], elements, documentRef);
    setRequestPending(elements, true);
    try {
        const payload = collectConversionRequest(elements);
        const result = await sendRequest(payload);
        showOutput(result.success ? result.code : '');
        renderMessages(result.errors, result.warnings, elements, documentRef, payload.command);
        revealErrors(elements, documentRef);
        return result.success;
    } catch (error) {
        showOutput('');
        renderMessages([{ message: REQUEST_ERROR_MESSAGE }], [], elements, documentRef);
        revealErrors(elements, documentRef);
        return false;
    } finally {
        setRequestPending(elements, false);
    }
}

export function bindConversionForm({ elements, convert, documentRef }) {
    const state = { conversionInProgress: false, repeatConversion: false };
    const runConversion = async () => {
        if (state.conversionInProgress) {
            return;
        }
        state.conversionInProgress = true;
        try {
            do {
                state.repeatConversion = false;
                await convert();
            } while (state.repeatConversion && elements.form.checkValidity());
        } finally {
            state.conversionInProgress = false;
        }
    };
    const convertIfValid = () => {
        if (!elements.form.checkValidity()) {
            return;
        }
        if (state.conversionInProgress) {
            state.repeatConversion = true;
            return;
        }
        void runConversion();
    };
    elements.form.addEventListener('submit', (event) => {
        event.preventDefault();
        void runConversion();
    });
    elements.command.addEventListener('invalid', () => elements.command.setAttribute('aria-invalid', 'true'));
    elements.command.addEventListener('input', () => {
        if (elements.command.checkValidity()) {
            elements.command.removeAttribute('aria-invalid');
        }
    });
    for (const button of elements.localeButtons) {
        button.addEventListener('click', () => {
            const localeChanged = selectedLocale(elements) !== button.value;
            setLocale(elements, button.value);
            if (localeChanged) {
                convertIfValid();
            }
        });
    }
    for (const option of elements.generatorOptions) {
        option.addEventListener('change', convertIfValid);
    }
    elements.jsonCheckbox.addEventListener('change', convertIfValid);
    documentRef.addEventListener('keydown', (event) => {
        if (event.key === 'Enter' && event.ctrlKey && !event.isComposing) {
            event.preventDefault();
            elements.form.requestSubmit();
        }
    });
}

export async function initializeApplication({ elements, loadHighlighter, showCriticalError }) {
    setBusy(elements, true);
    try {
        const highlighter = await loadHighlighter();
        setBusy(elements, false);
        return highlighter;
    } catch (error) {
        elements.output.setAttribute('aria-busy', 'false');
        showCriticalError(HIGHLIGHTER_ERROR_MESSAGE);
        return null;
    }
}

function collectElements(documentRef) {
    const command = documentRef.getElementById('command');
    const convertButton = documentRef.getElementById('convert');
    const generatorOptions = Array.from(documentRef.querySelectorAll('input[name="target"]'));
    const jsonCheckbox = documentRef.getElementById('json-option');
    const localeButtons = Array.from(documentRef.querySelectorAll('button[name="locale"]'));
    const tooltip = documentRef.querySelector('.tooltip');
    return {
        form: documentRef.getElementById('curl-form'), command, convertButton, generatorOptions, jsonCheckbox,
        localeButtons, output: documentRef.getElementById('output'), copyButton: documentRef.getElementById('copy'),
        errors: documentRef.getElementById('errors'), warnings: documentRef.getElementById('warnings'), tooltip,
        tooltipDetails: tooltip.querySelector('details'),
        requestControls: [command, convertButton, ...generatorOptions, jsonCheckbox, ...localeButtons],
        requestPending: false
    };
}

async function loadHighlighter() {
    const [themeModule, languageModule, coreModule, engineModule] = await Promise.all([
        import('./shiki/themes/github-light.js'), import('./shiki/langs/bsl.js'),
        import('./shiki/core.js'), import('./shiki/engine/oniguruma.js')
    ]);
    return coreModule.createHighlighterCore({
        themes: [themeModule.default], langs: [languageModule.default],
        engine: engineModule.createOnigurumaEngine(import('./shiki/wasm.js'))
    });
}

function renderOutput(highlighter, output, code) {
    output.innerHTML = highlighter.codeToHtml(code, { lang: 'bsl', theme: 'github-light' });
}

async function startApplication(documentRef, windowRef) {
    const elements = collectElements(documentRef);
    let outputText = '';
    elements.tooltip.addEventListener('mouseleave', () => { elements.tooltipDetails.open = false; });
    const highlighter = await initializeApplication({
        elements, loadHighlighter,
        showCriticalError: (message) => renderMessages([{ message }], [], elements, documentRef)
    });
    if (highlighter === null) {
        return;
    }

    const showOutput = (code) => {
        outputText = code;
        renderOutput(highlighter, elements.output, code);
    };
    const convert = () => submitConversion({
        elements,
        requestConversion: (payload) => requestConversion(windowRef.fetch.bind(windowRef), payload),
        showOutput,
        documentRef
    });
    bindConversionForm({ elements, convert, documentRef });
    showOutput('');
    elements.copyButton.disabled = false;
    elements.copyButton.addEventListener('click', async () => {
        await copyOutput({ clipboard: windowRef.navigator.clipboard, outputText, elements, documentRef });
    });
}

if (typeof window !== 'undefined' && typeof document !== 'undefined') {
    void startApplication(document, window);
}
