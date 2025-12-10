<template>
  <div class="module-view">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div><div class="module-view-info"><h1>Carátula de Locales</h1><p>Inicio > Reportes > Carátula de Locales</p></div><div class="button-group ms-auto"><button class="btn-municipal-primary" @click="imprimir" :disabled="loading || !result"><font-awesome-icon icon="print" />Imprimir</button><button class="btn-municipal-purple" @click="mostrarAyuda"><font-awesome-icon icon="question-circle" />Ayuda</button></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="search" />Buscar Local</h5></div><div class="municipal-card-body"><div class="row"><div class="col-md-4"><label class="municipal-form-label">ID Local</label><input v-model.number="filters.id_local" type="number" class="municipal-form-control" /></div><div class="col-md-8"><button class="btn-municipal-primary mt-4" @click="consultar" :disabled="loading"><font-awesome-icon icon="search" />Consultar Carátula</button></div></div></div></div>
      <div class="municipal-card" v-if="result"><div class="municipal-card-header"><h5><font-awesome-icon icon="info-circle" />Datos del Local</h5></div><div class="municipal-card-body"><table class="table table-bordered"><tr><th>Nombre</th><td>{{ result.nombre }}</td></tr><tr><th>Domicilio</th><td>{{ result.domicilio }}</td></tr><tr><th>Sector</th><td>{{ result.sector }}</td></tr><tr><th>Superficie</th><td>{{ result.superficie }}</td></tr><tr><th>Vigencia</th><td>{{ result.vigdescripcion }}</td></tr><tr><th>Renta</th><td>{{ formatCurrency(result.renta) }}</td></tr><tr><th>Adeudo</th><td>{{ formatCurrency(result.adeudo) }}</td></tr><tr><th>Total</th><td><strong>{{ formatCurrency(result.total) }}</strong></td></tr></table></div></div>
    </div>
    <div v-if="toast.show" :class="['toast-notification', `toast-${toast.type}`]"><font-awesome-icon :icon="getToastIcon()" /><span>{{ toast.message }}</span></div>
  </div>
</template>
<script setup>
import { ref } from 'vue'; import axios from 'axios';
const loading = ref(false); const result = ref(null); const filters = ref({ id_local: '' }); const toast = ref({ show: false, message: '', type: 'info' });
const consultar = async () => { if (!filters.value.id_local) { showToast('Debe ingresar un ID de local', 'warning'); return; } loading.value = true; result.value = null; try { const response = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_rpt_caratula_datos', Base: 'mercados', Parametros: [filters.value.id_local, 0, 0, 0, 0, 0, 0, '', ''] } }); if (response.data.eResponse?.success && response.data.eResponse?.data?.result) { result.value = response.data.eResponse.data.result[0]; showToast('Carátula generada correctamente', 'success'); } else { showToast('No se encontraron datos', 'warning'); } } catch (error) { console.error('Error:', error); showToast('Error al consultar', 'error'); } finally { loading.value = false; } };
const imprimir = () => { window.print(); }; const mostrarAyuda = () => { showToast('Ingrese un ID de local para consultar la carátula.', 'info'); }; const formatCurrency = (value) => { if (value === null || value === undefined) return '$0.00'; return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value); }; const showToast = (message, type = 'info') => { toast.value = { show: true, message, type }; setTimeout(() => { toast.value.show = false; }, 3000); }; const getToastIcon = () => { const icons = { success: 'check-circle', error: 'exclamation-circle', warning: 'exclamation-triangle', info: 'info-circle' }; return icons[toast.value.type] || 'info-circle'; };
</script>
<style scoped>
@media print {
  .module-view-header,
  .button-group {
    display: none !important;
  }
}

.button-group {
  display: inline-flex;
  gap: 0.25rem;
}

.button-group-sm {
  gap: 0.125rem;
}

.module-view-header .btn-municipal-primary,
.module-view-header .btn-municipal-primary {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: white !important;
}

.toast-notification {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  padding: 1rem 1.5rem;
  border-radius: 0.5rem;
  background-color: #fff;
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
  display: flex;
  align-items: center;
  gap: 0.75rem;
  z-index: 9999;
  animation: slideIn 0.3s ease-out;
}

.toast-success {
  border-left: 4px solid #28a745;
}

.toast-error {
  border-left: 4px solid #dc3545;
}

.toast-warning {
  border-left: 4px solid #ffc107;
}

.toast-info {
  border-left: 4px solid #17a2b8;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
</style>
