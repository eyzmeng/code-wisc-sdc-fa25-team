/* some voodoo magic here? <https://svelte.dev/docs/svelte/stores> */
import { writable } from 'svelte/store';
export const strbuf = writable('');
