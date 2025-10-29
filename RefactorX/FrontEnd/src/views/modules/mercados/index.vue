<template>
  <div class="module-view">
    <h1><font-awesome-icon icon="store" /> Mercados</h1>
    <div class="module-content">
      <p>Módulo en desarrollo...</p>
    </div>
  </div>
</template>

<script setup>
import { useApi } from '@/composables/useApi'

const { loading, error, data, execute } = useApi()
</script>


