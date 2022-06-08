import { users } from '../static/users';

describe('/users/sign_in', () => {
  it('login test', () => {
    cy.login(users.hr);
    cy.wait(100);
    cy.url().should('not.contain', '/users/sign_in');
    cy.get('meta[name="csrf-param"]').should('have.attr', 'content', 'authenticity_token');
    cy.get('meta[name="csrf-token"]').invoke('attr', 'content').should('have.length.above', 0);
  });

  it('logout test', () => {
    cy.logout();
    cy.url().should('contain', '/users/sign_in');
    cy.get('#wrapper').should('contain', 'Signed out successfully');
  });
});
