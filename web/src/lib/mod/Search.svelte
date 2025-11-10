<script>
  import search from '$lib/sub/search';
  import Console from '$lib/debug/Console.svelte';

  var query = '';
  var selectedTags = [];
  var memberFee = '';
  var registration = '';
  var activeMembers = '';
  var clubAge = '';
  var audience = '';

  const tags = ['Sports', 'Music', 'Art', 'STEM', 'Cultural'];
  const toggleTag = (tag) => {
    selectedTags = selectedTags.includes(tag)
      ? selectedTags.filter((t) => t !== tag)
      : [...selectedTags, tag];
  };
  const getQueryParams = () => ({
    query,
    selectedTags,
    memberFee,
    registration,
    activeMembers,
    clubAge,
    audience
  });

  const submit = () => {
    search(getQueryParams());
  };
</script>

<div class="max-w-lg m-auto space-y-6">
  <div>
    <label for="query" class="font-semibold block mb-1">Search</label>
    <input
      id="query"
      type="text"
      bind:value={query}
      placeholder="Search clubs..."
      class="w-full border rounded-lg p-2"
    />
  </div>

  <div class="filters space-y-4">
    <!-- Tags -->
    <div>
      <label for={tags.map((elt, i) => 'tag-' + i).join(' ')} class="font-semibold block mb-2"
        >Tags:</label
      >
      <div class="flex flex-wrap gap-2">
        {#each tags as tag, i (i)}
          <button
            id="{tag}.{i}"
            type="button"
            class="px-3 py-1 rounded-full border text-sm transition-colors
                   {selectedTags.includes(tag)
              ? 'bg-gray-800 text-white border-gray-800'
              : 'bg-gray-100 hover:bg-gray-200'}"
            on:click={() => toggleTag(tag)}
          >
            {tag}
          </button>
        {/each}
      </div>
    </div>

    <!-- Member fee -->
    <div>
      <label for="fee" class="font-semibold block mb-1">Member fee:</label>
      <select id="fee" bind:value={memberFee} class="border rounded-lg p-2 w-full">
        <option value="">(any)</option>
        <option>Free to join</option>
        <option>Costs $25 per semester</option>
        <option>Other</option>
      </select>
    </div>

    <!-- Registration -->
    <div>
      <label for="barrier" class="font-semibold block mb-1">Registration:</label>
      <select id="barrier" bind:value={registration} class="border rounded-lg p-2 w-full">
        <option value="">(any)</option>
        <option>Open</option>
        <option>Apply-only</option>
        <option>Closed</option>
      </select>
    </div>

    <!-- Active members -->
    <div>
      <label for="activity" class="font-semibold block mb-1">Active member #:</label>
      <select id="activity" bind:value={activeMembers} class="border rounded-lg p-2 w-full">
        <option value="">(any)</option>
        <option>Few</option>
        <option>Many</option>
      </select>
    </div>

    <!-- Club age -->
    <div>
      <label for="age" class="font-semibold block mb-1">Club age:</label>
      <select id="age" bind:value={clubAge} class="border rounded-lg p-2 w-full">
        <option value="">(any)</option>
        <option>New</option>
        <option>Old</option>
      </select>
    </div>

    <!-- Audience -->
    <div>
      <label for="class" class="font-semibold block mb-1">Audience:</label>
      <select id="class" bind:value={audience} class="border rounded-lg p-2 w-full">
        <option value="">(any)</option>
        <option>Undergraduate</option>
        <option>Graduate</option>
        <option>Open</option>
      </select>
    </div>
  </div>

  <!-- Submit -->
  <form on:submit|preventDefault={submit} class="pt-4">
    <button type="submit" class="bg-blue-600 text-white rounded-lg px-4 py-2 hover:bg-blue-700">
      Search
    </button>
  </form>
</div>
<Console />
