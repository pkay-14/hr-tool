function showProjectLocalScope() {
  function checkTextField(field, container) {
    if (!field) return;

    if (field.textContent.trim().length === 0) {
      container.style.display = 'none';
    }
  }

  function checkTextFields() {
    const businessDomains = document.querySelector('#business-domains');
    const businessDomainsSpan = document.querySelector('#business-domains__span');
    const graylogNames = document.querySelector('#graylog-names');
    const graylogNamesSpan = document.querySelector('#graylog-names__span');
    const errbitKeys = document.querySelector('#errbit-keys');
    const errbitKeysSpan = document.querySelector('#errbit-keys__span');
    const projectUrl = document.querySelector('#project-url');
    const projectUrlSpan = document.querySelector('#project-url__span');

    checkTextField(businessDomainsSpan, businessDomains);
    checkTextField(graylogNamesSpan, graylogNames);
    checkTextField(errbitKeysSpan, errbitKeys);
    checkTextField(projectUrlSpan, projectUrl);
  }

  function init() {
    checkTextFields();
  }

  $(document).ready(init);
}

if (location.pathname.match(/manager\/projects\/.*/)) {
  showProjectLocalScope.call(this);
}
