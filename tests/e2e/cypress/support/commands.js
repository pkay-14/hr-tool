// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })

Cypress.Commands.add('ignoreReferenceErrors', () => {
  cy.on('uncaught:exception', (err, runnable) => {
    if (err.name.includes('ReferenceError')) {
      return false
    }
  });
})

Cypress.Commands.add('login', (user) => {
  cy.visit('/');
  cy.get('#user_moc_email').type(user.email);
  cy.get('#user_password').type(user.password);
  cy.get('#new_user').submit();
})

Cypress.Commands.add('logout', () => {
  cy.get('a[href*="users/sign_out"]').focus().click();
})
