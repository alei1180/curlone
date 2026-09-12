import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const source = await readFile(new URL('../../src/interface/view/static/index.js', import.meta.url), 'utf8');
const moduleUrl = `data:text/javascript;base64,${Buffer.from(source).toString('base64')}`;
const interfaceModule = await import(moduleUrl);

test('общая логика отправки формы не зависит от транспорта HTTP API', async () => {
    const attributes = new Map([['aria-busy', 'false']]);
    const requestControl = {
        toggleAttribute() {}
    };
    const messageContainer = {
        hidden: true,
        replaceChildren() {},
        append() {}
    };
    const elements = {
        requestControls: [requestControl],
        output: {
            getAttribute: (name) => attributes.get(name),
            setAttribute: (name, value) => attributes.set(name, value)
        },
        command: {
            removeAttribute() {}
        },
        warnings: { ...messageContainer },
        errors: { ...messageContainer }
    };
    let shownOutput = '';

    const result = await interfaceModule.submitConversion({
        elements,
        form: { checkValidity: () => true },
        requestConversion: async () => ({ result: 'Код', errors: [] }),
        showOutput: (value) => { shownOutput = value; },
        documentRef: {
            createElement: () => ({}),
            createTextNode: (value) => value,
            defaultView: null
        }
    });

    assert.equal(result, true);
    assert.equal(shownOutput, 'Код');
    assert.equal(attributes.get('aria-busy'), 'false');
});

test('обработчик формы запускает переданную конвертацию', () => {
    const listeners = new Map();
    const eventTarget = () => ({
        addEventListener: (name, listener) => listeners.set(name, listener)
    });
    const elements = {
        form: eventTarget(),
        command: {
            ...eventTarget(),
            checkValidity: () => true,
            removeAttribute() {},
            value: ''
        },
        generatorOptions: [],
        localeButtons: [],
        jsonCheckbox: eventTarget(),
        errors: { textContent: '' }
    };
    let conversionCount = 0;
    let prevented = false;

    interfaceModule.bindConversionForm({
        elements,
        convert: () => { conversionCount += 1; },
        refreshOutput() {},
        documentRef: eventTarget()
    });
    listeners.get('submit')({ preventDefault: () => { prevented = true; } });

    assert.equal(conversionCount, 1);
    assert.equal(prevented, true);
});
