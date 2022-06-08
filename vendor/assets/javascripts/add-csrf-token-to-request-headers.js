function addCsrfTokenToRequestHeaders(requestHeaders) {
  const tokenDomElement = document.querySelector('meta[name="csrf-token"]');

  if (tokenDomElement) {
    requestHeaders.append('X-CSRF-Token', tokenDomElement.content);
  }

  return requestHeaders;
}
