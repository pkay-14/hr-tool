/**
 * @description Adds validation which allow enter to input element only numbers and limits the digits after a period (point)
 * @example addNumberValidationForInputField(inputDomElement, 1);
 * allows only numbers like 27.1 for inputDomElement, 27.15 will be restricted
 * @param {HTMLElement} inputDomElement HTML input element. Example: inputDomElement = document.querySelector('#my-element')
 * @param {Number} numberDigitsAfterPointCount maximum number of digits after point (after separator)
 */
function addNumberValidationForInputField(inputDomElement, numberDigitsAfterPointCount = 1) {
  if (!inputDomElement) {
    return;
  }

  let oldValue = '';
  let cursorPosition = 0;

  // save previous value
  inputDomElement.addEventListener('beforeinput', (event) => {
    const inputElement = event.target;

    oldValue = inputElement.value;
    let eventData = event.data;

    if (eventData === '.' && inputElement.value[inputElement.selectionStart] === '.') {
      cursorPosition = inputElement.selectionStart + 1;
    } else {
      cursorPosition = inputElement.selectionStart;
    }
  });

  function generateRegexp() {
    return numberDigitsAfterPointCount
      ? new RegExp(`^[0-9]*[.]?[0-9]{0,${numberDigitsAfterPointCount}}$`)
      : new RegExp(`^[0-9]*$`);
  }

  // validate and set old value if new value is incorrect
  inputDomElement.addEventListener('input', (event) => {
    const inputElement = event.target;

    if (!inputElement.value.match(generateRegexp())) {
      inputElement.value = oldValue;

      if (inputElement.value[cursorPosition - 1] === '.') {
        inputElement.selectionStart = cursorPosition;
        inputElement.selectionEnd = cursorPosition + 1;
      } else {
        inputElement.selectionStart = cursorPosition;
        inputElement.selectionEnd = cursorPosition;
      }
    }
  });

  inputDomElement.addEventListener('change', (event) => {
    const inputElement = event.target;

    if (inputElement.value.startsWith('.')) {
      inputElement.value = `0${inputElement.value}`;
    }

    if (inputElement.value === '') {
      inputElement.value = '0';
    }

    if (numberDigitsAfterPointCount) {
      if (!inputElement.value.includes('.')) {
        inputElement.value += '.';
      }

      if (inputElement.value.endsWith('.')) {
        inputElement.value += '0';
      }
    }
  });
}