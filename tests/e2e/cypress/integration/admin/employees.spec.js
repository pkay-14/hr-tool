import {users} from "/tests/e2e/cypress/static/users";

describe('/admin/employees', () => {
  it('opened test', () => {
    cy.login(users.hr);
    cy.get('a.mm-menu__link[href*="admin/employees"]').focus().click();
    cy.window().contains('Masters');
    cy.logout();
  });
})
