<script lang="ts">
	import favicon from '$lib/assets/favicon.svg';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

{@render children?.()}

<hr>
<footer>
	<p><em>
		This site is run by <a href="https://rapidcow.github.io/site-wisc-sdc-fa25-team/">SDC Fall 2025 Team 17</a>.
		Please review the <a href="https://team.endfindme.com/wisc/sdc/fa-25/public/privacy-policy">Privacy Policy</a>
		before using this service.
	</em></p>
</footer>
