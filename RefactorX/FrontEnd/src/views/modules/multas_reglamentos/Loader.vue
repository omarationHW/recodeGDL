<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="gavel" /></div>
      <div class="module-view-info">
        <h1>{{ title }}</h1>
        <p v-if="error" class="text-danger">{{ error }}</p>
      </div>
    </div>

    <component v-if="Component" :is="Component" />

    <div v-else class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <p class="text-muted">Componente no implementado aún o nombre inválido.</p>
          <p class="text-muted">Vista solicitada: <code>{{ viewName }}</code></p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const Component = ref(null)
const error = ref('')
const viewName = ref('')
const title = ref('Multas y Reglamentos')

async function load() {
  error.value = ''
  Component.value = null
  viewName.value = route.params.view
  title.value = `Multas y Reglamentos · ${String(viewName.value || '')}`

  try {
    const mod = await import(`./${viewName.value}.vue`)
    Component.value = mod.default || mod
  } catch (e) {
    error.value = 'No se pudo cargar la vista solicitada.'
  }
}

onMounted(load)
watch(() => route.params.view, load)
</script>

