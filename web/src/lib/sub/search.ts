import { strbuf } from '$lib/debug/conctl';
import { getenv } from '$lib/etc/environ';

export default (query) => {
  fetch(`${getenv('API_BASE_URL')}/v1/search`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(query)
  })
    /* response.json() returns yet ANOTHER Promise: =_=
     * https://stackoverflow.com/q/39435842/19411800 */
    .then((response) => response.json())
    .then((payload) => strbuf.set(JSON.stringify(payload, null, 2)))
    .catch((err) => {
      strbuf.set(`Uh oh, error: ${(err as Error).message}`);
    });
};
