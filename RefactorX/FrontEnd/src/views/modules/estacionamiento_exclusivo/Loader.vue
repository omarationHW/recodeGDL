<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="gavel" /></div>
      <div class="module-view-info"><h1>Apremios SVN · {{ viewName }}</h1></div>
    </div>
    <component v-if="Component" :is="Component" />
    <div v-else class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body"><p class="text-muted">Vista no encontrada: <code>{{ viewName }}</code></p></div></div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const viewName = ref('')
const Component = ref(null)

async function load() {
  viewName.value = route.params.view
  try {
    const mod = await import(`./${viewName.value}.vue`)
    Component.value = mod.default || mod
  } catch (e) {
    Component.value = null
  }
}

onMounted(load)
watch(() => route.params.view, load)
</script>

