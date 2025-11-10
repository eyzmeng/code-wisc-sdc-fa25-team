# web - Frontend code

## Development

You should have read HACKING already.

Start development server using:

```
pnpm dev
vite dev
```

By default, Vite binds to the loopback interface on port 5173.
If it cannot bind to that, it will try 5714, and I guess it would
try 5715 next, and... I don't know.  I haven't tried that much.

Take port 5173 for example.  You want to access <http://localhost:5173/>.
(The host name is very significant.  **Do not use 127.0.0.1**.)

You can override these using `--host [host]` and `--port [port]`.


## Structure

Frontend HTML/CSS people, work on `src/lib/mod`,
which are concerned with UI components.

Frontend JavaScript people, work on `src/lib/sub`,
which are concerned with implementing these components.

*To frontend programmers (JavaScript) that is*:
You can use the `src/lib/debug/Console.svelte` component to
display debug messages.  Example:

```svelte
<script lang="ts">
  import { strbuf } from '$lib/debug/conctl';
  import Console from '$lib/debug/Console.svelte';
</script>

<button on:click={() => strbuf.set("Hello World")}>Press me</button>
<Console />
```

(You can also use the real JavaScript console in your
DevTools panel if you know what that is.)

Use `getenv` from `src/lib/api/etc/environ.ts` to obtain dynamic
environment variables.  The `getenv('API_BASE_URL')` is
what you should use for the base URL of the API.
To get a greeting, for instance, you'd write:

```svelte
<script lang="ts">
   import { getenv } from '$lib/debug/etc/environ';
   const url = `${getenv('API_BASE_URL')}v1/greet`;
   fetch($url).then(res => res.json()).then(payload => do_something(payload))
     .catch(err => console.error(`Bad ${url}!`, err));
</script>
```
