<!-- Pop-up debug panel -->
<script lang="ts">
  import { strbuf } from './conctl';
</script>

{#if $strbuf !== ''}
  <div
    class="fixed bottom-14 right-4 w-96 h-64 bg-black bg-opacity-90 text-green-300
         font-mono text-sm rounded-lg border border-green-600 shadow-lg z-50
         flex flex-col"
  >
    <!-- Header -->
    <div class="flex justify-between items-center px-3 py-2 border-b border-green-600">
      <span class="font-semibold">Debug Log</span>
      <button
        on:click={() => strbuf.set('')}
        class="text-red-400 hover:text-red-200 text-xs uppercase tracking-wide"
      >
        Clear
      </button>
    </div>

    <!-- Scrollable log area -->
    <div class="flex-1 overflow-y-auto p-2">
      <!-- Split (CR)LF https://stackoverflow.com/a/5035005/19411800 -->
      {#each $strbuf.split(/\r?\n/) as line, i (i)}
        <pre>{line}</pre>
      {:else}
        <div class="opacity-50 italic">(empty)</div>
      {/each}
    </div>
  </div>
{/if}
