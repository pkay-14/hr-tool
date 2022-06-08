function editProjectLocalScope() {
  function checkInputValue(input, block) {
    if (!input) return;

    if (input.value.length === 0) {
      block.style.display = 'none';
    }
  }

  function checkInputsValue() {
    const graylogNamesInput = document.querySelector('#project_graylog_names');
    const graylogNamesItem = document.querySelector('#graylog-names__item');
    const businessDomainsInput = document.querySelector('#project_business_domains');
    const businessDomainsItem = document.querySelector('#business-domains__item');
    const errbitKeysInput = document.querySelector('#project_errbit_keys');
    const errbitKeysItem = document.querySelector('#errbit-keys__item');
    const projectUrlInput = document.querySelector('#project_project_url');
    const projectUrlItem = document.querySelector('#project-url__item');

    checkInputValue(graylogNamesInput, graylogNamesItem);
    checkInputValue(businessDomainsInput, businessDomainsItem);
    checkInputValue(errbitKeysInput, errbitKeysItem);
    checkInputValue(projectUrlInput, projectUrlItem);
  }

  function init() {
    checkInputsValue();
  }

  $(document).ready(init);
}

if (location.pathname.match(/manager\/projects\/.*edit/)) {
  editProjectLocalScope.call(this);
}
