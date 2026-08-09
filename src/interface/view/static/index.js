const DEFAULT_OUTPUTS = {
    '1c': {
        ru: 'Соединение = Новый HTTPСоединение("example.com", 80);\n'
            + 'HTTPЗапрос = Новый HTTPЗапрос("/");\n\n'
            + 'HTTPОтвет = Соединение.ВызватьHTTPМетод("GET", HTTPЗапрос);',
        en: 'Connection = New HTTPConnection("example.com", 80);\n'
            + 'HTTPRequest = New HTTPRequest("/");\n\n'
            + 'HTTPResponse = Connection.CallHTTPMethod("GET", HTTPRequest);'
    },
    'connector': {
        ru: 'Результат = КоннекторHTTP.Get("http://example.com");',
        en: 'Result = HTTPConnector.Get("http://example.com");'
    }
};

const REQUEST_ERROR_MESSAGE = 'Не удалось выполнить запрос';
const HIGHLIGHTER_ERROR_MESSAGE = 'Не удалось инициализировать подсветку синтаксиса';
const REQUIRED_COMMAND_MESSAGE = 'Введите команду curl';

export function setBusy(elements, isBusy) {
    for (const control of elements.requestControls) {
        control.disabled = isBusy;
    }

    elements.output.setAttribute('aria-busy', String(isBusy));
}

export function setRequestPending(elements, isPending) {
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

function appendMessages(container, records, documentRef) {
    container.replaceChildren();

    records.forEach((record, index) => {
        if (index > 0) {
            container.append(documentRef.createElement('br'));
        }

        container.append(documentRef.createTextNode(record.text));
    });

    container.hidden = records.length === 0;
}

export function renderMessages(records, elements, documentRef) {
    const warnings = records.filter((record) => !record.critical);
    const errors = records.filter((record) => record.critical);

    appendMessages(elements.warnings, warnings, documentRef);
    appendMessages(elements.errors, errors, documentRef);
}

function revealCriticalMessages(elements, documentRef) {
    const windowRef = documentRef.defaultView;
    const isMobile = windowRef?.matchMedia?.('(max-width: 36rem)').matches ?? false;

    if (!elements.errors.hidden && isMobile && typeof elements.errors.scrollIntoView === 'function') {
        elements.errors.scrollIntoView({ block: 'nearest' });
    }
}

function selectedValue(elements) {
    return elements.generatorOptions.find((option) => option.checked)?.value ?? '1c';
}

function selectedLocale(elements) {
    return elements.localeButtons.find((button) => button.getAttribute('aria-pressed') === 'true')?.value ?? 'ru';
}

function requestParameters(elements) {
    return {
        cmd: elements.command.value,
        lang: selectedValue(elements),
        locale: selectedLocale(elements),
        'response-type': elements.jsonCheckbox.checked ? 'json' : ''
    };
}

function isConversionResponse(response) {
    return response !== null
        && typeof response === 'object'
        && typeof response.result === 'string'
        && Array.isArray(response.errors);
}

export function createRequestBody(parameters) {
    return new URLSearchParams(parameters).toString().replaceAll('+', '%20');
}

export async function submitConversion({
    elements,
    form,
    requestConversion,
    showOutput,
    documentRef
}) {
    if (!form.checkValidity()) {
        elements.command.setAttribute('aria-invalid', 'true');
        renderMessages([{ text: REQUIRED_COMMAND_MESSAGE, critical: true }], elements, documentRef);
        elements.command.focus();
        revealCriticalMessages(elements, documentRef);
        return false;
    }

    if (elements.output.getAttribute('aria-busy') === 'true') {
        return false;
    }

    elements.command.removeAttribute('aria-invalid');
    renderMessages([], elements, documentRef);
    setRequestPending(elements, true);

    try {
        const response = await requestConversion(requestParameters(elements));
        if (!isConversionResponse(response)) {
            throw new TypeError('Invalid conversion response');
        }

        const hasCriticalErrors = response.errors.some((record) => record.critical);

        showOutput(hasCriticalErrors ? '' : response.result);
        renderMessages(response.errors, elements, documentRef);
        revealCriticalMessages(elements, documentRef);
        return true;
    } catch (error) {
        showOutput('');
        renderMessages([{ text: REQUEST_ERROR_MESSAGE, critical: true }], elements, documentRef);
        revealCriticalMessages(elements, documentRef);
        return false;
    } finally {
        setRequestPending(elements, false);
    }
}

export async function initializeApplication({
    elements,
    loadHighlighter,
    showDefaultOutput,
    showCriticalError
}) {
    setBusy(elements, true);

    try {
        const highlighter = await loadHighlighter();
        showDefaultOutput(highlighter);
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
    const generatorOptions = Array.from(documentRef.querySelectorAll('input[name="lang"]'));
    const jsonCheckbox = documentRef.getElementById('json-option');
    const localeButtons = Array.from(documentRef.querySelectorAll('button[name="locale"]'));
    const tooltip = documentRef.querySelector('.tooltip');

    return {
        form: documentRef.getElementById('curl-form'),
        command,
        convertButton,
        generatorOptions,
        jsonCheckbox,
        localeButtons,
        output: documentRef.getElementById('output'),
        copyButton: documentRef.getElementById('copy'),
        errors: documentRef.getElementById('errors'),
        warnings: documentRef.getElementById('warnings'),
        tooltip,
        tooltipDetails: tooltip.querySelector('details'),
        requestControls: [
            command,
            convertButton,
            ...generatorOptions,
            jsonCheckbox,
            ...localeButtons
        ]
    };
}

async function loadHighlighter() {
    const [themeModule, languageModule, coreModule, engineModule] = await Promise.all([
        import('./shiki/themes/github-light.js'),
        import('./shiki/langs/bsl.js'),
        import('./shiki/core.js'),
        import('./shiki/engine/oniguruma.js')
    ]);

    return coreModule.createHighlighterCore({
        themes: [themeModule.default],
        langs: [languageModule.default],
        engine: engineModule.createOnigurumaEngine(import('./shiki/wasm.js'))
    });
}

async function postConversion(parameters, fetchRef) {
    const response = await fetchRef('/api/v1/convert', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: createRequestBody(parameters)
    });

    if (!response.ok) {
        throw new Error(`Conversion failed with HTTP ${response.status}`);
    }

    return response.json();
}

function renderOutput(highlighter, output, code) {
    output.innerHTML = highlighter.codeToHtml(code, {
        lang: 'bsl',
        theme: 'github-light'
    });
}

async function startApplication(documentRef, windowRef) {
    const elements = collectElements(documentRef);
    let highlighter = null;
    let outputText = '';

    elements.tooltip.addEventListener('mouseleave', () => {
        elements.tooltipDetails.open = false;
    });

    const showOutput = (code) => {
        outputText = code;
        renderOutput(highlighter, elements.output, code);
    };

    const showDefaultOutput = (loadedHighlighter) => {
        highlighter = loadedHighlighter;
        const code = DEFAULT_OUTPUTS[selectedValue(elements)][selectedLocale(elements)];
        showOutput(code);
    };

    highlighter = await initializeApplication({
        elements,
        loadHighlighter,
        showDefaultOutput,
        showCriticalError: (message) => renderMessages([
            { text: message, critical: true }
        ], elements, documentRef)
    });

    if (highlighter === null) {
        return;
    }

    elements.copyButton.disabled = false;

    const convert = () => submitConversion({
        elements,
        form: elements.form,
        requestConversion: (parameters) => postConversion(parameters, windowRef.fetch.bind(windowRef)),
        showOutput,
        documentRef
    });

    const refreshOutput = () => {
        if (elements.command.value) {
            elements.form.requestSubmit();
            return;
        }

        showDefaultOutput(highlighter);
        renderMessages([], elements, documentRef);
    };

    elements.form.addEventListener('submit', (event) => {
        event.preventDefault();
        void convert();
    });

    elements.command.addEventListener('invalid', () => {
        elements.command.setAttribute('aria-invalid', 'true');
    });

    elements.command.addEventListener('input', () => {
        if (elements.command.checkValidity()) {
            elements.command.removeAttribute('aria-invalid');

            if (elements.errors.textContent === REQUIRED_COMMAND_MESSAGE) {
                renderMessages([], elements, documentRef);
            }
        }

        if (!elements.command.value) {
            refreshOutput();
        }
    });

    for (const option of elements.generatorOptions) {
        option.addEventListener('change', refreshOutput);
    }

    for (const button of elements.localeButtons) {
        button.addEventListener('click', () => {
            setLocale(elements, button.value);
            refreshOutput();
        });
    }

    elements.jsonCheckbox.addEventListener('change', refreshOutput);

    elements.copyButton.addEventListener('click', async () => {
        try {
           await windowRef.navigator.clipboard.writeText(outputText);
        } catch (error) {
            renderMessages([{ text: 'Не удалось скопировать код', critical: true }], elements, documentRef);
        }
    });

    documentRef.addEventListener('keydown', (event) => {
        if (event.key === 'Enter' && event.ctrlKey) {
            event.preventDefault();
            elements.form.requestSubmit();
        }
    });
}

if (typeof window !== 'undefined' && typeof document !== 'undefined') {
    void startApplication(document, window);
}
