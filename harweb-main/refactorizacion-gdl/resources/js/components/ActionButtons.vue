<template>
  <div class="action-buttons">
    <button @click="$emit('nuevo-contrato')" class="btn-primary">
      ➕ Alta Contrato
    </button>
    <button @click="$emit('exportar-excel')" class="btn-secondary">
      📊 Exportar a Excel
    </button>
    <button @click="$emit('generar-pdf')" class="btn-info">
      📄 Generar PDF
    </button>
    <button @click="$emit('actualizar')" class="btn-secondary">
      🔄 Actualizar
    </button>
  </div>
</template>

<script>
export default {
  name: 'ActionButtons',
  emits: ['nuevo-contrato', 'exportar-excel', 'generar-pdf', 'actualizar']
}
</script>