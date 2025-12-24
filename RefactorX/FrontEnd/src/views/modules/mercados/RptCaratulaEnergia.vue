<template>
  <div class="module-view">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="bolt" /></div><div class="module-view-info"><h1>Carátula de Energía</h1><p>Inicio > Reportes > Carátula de Energía Eléctrica</p></div><div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        <button class="btn-municipal-primary" @click="imprimir" :disabled="loading || !caratula"><font-awesome-icon icon="print" />Imprimir</button></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="search" />Buscar Local</h5></div><div class="municipal-card-body"><div class="row"><div class="col-md-4"><label class="municipal-form-label">ID Local</label><input v-model.number="id_local" type="number" class="municipal-form-control" /></div><div class="col-md-8"><button class="btn-municipal-primary mt-4" @click="fetchCaratula" :disabled="loading"><font-awesome-icon icon="search" />Consultar</button></div></div></div></div>
      <div class="municipal-card" v-if="caratula"><div class="municipal-card-header"><h5><font-awesome-icon icon="info-circle" />Datos del Local</h5></div><div class="municipal-card-body"><table class="table table-bordered"><tr><th>Oficina</th><td>{{ caratula.oficina }}</td></tr><tr><th>Mercado</th><td>{{ caratula.num_mercado }}</td></tr><tr><th>Local</th><td>{{ caratula.local }}</td></tr><tr><th>Nombre</th><td>{{ caratula.nombre }}</td></tr><tr><th>Consumo</th><td>{{ caratula.consumodescr }}</td></tr><tr><th>Cantidad</th><td>{{ caratula.cantidad }}</td></tr><tr><th>Vigencia</th><td>{{ caratula.vigdescripcion }}</td></tr></table></div></div>
    </div>
    <div v-if="toast.show" :class="['toast-notification', `toast-${toast.type}`]"><font-awesome-icon :icon="getToastIcon()" /><span>{{ toast.message }}</span></div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'RptCaratulaEnergia'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - RptCaratulaEnergia'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'RptCaratulaEnergia'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - RptCaratulaEnergia'" @close="showDocumentacion = false" />
</template>
<script setup>
import apiService from '@/services/apiService';
import { ref } from 'vue'; const loading = ref(false); const id_local = ref(''); const caratula = ref(null); const toast = ref({ show: false, message: '', type: 'info' });
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)

const fetchCaratula = async () => { if (!id_local.value) { showToast('Debe ingresar un ID de local', 'warning'); return; } loading.value = true; caratula.value = null; try { const response = await apiService.execute(
          'sp_get_energia_caratula',
          'mercados',
          [id_local.value],
          '',
          null,
          'publico'
        ); if (response?.success && response?.data?.result) { caratula.value = response.data.result[0]; showToast('Carátula generada correctamente', 'success'); } else { showToast('No se encontraron datos', 'warning'); } } catch (error) { console.error('Error:', error); showToast('Error al consultar', 'error'); } finally { loading.value = false; } };
const imprimir = () => { window.print(); }; const mostrarAyuda = () => { showToast('Ingrese un ID de local para consultar la carátula de energía.', 'info'); }; const showToast = (message, type = 'info') => { toast.value = { show: true, message, type }; setTimeout(() => { toast.value.show = false; }, 3000); }; const getToastIcon = () => { const icons = { success: 'check-circle', error: 'exclamation-circle', warning: 'exclamation-triangle', info: 'info-circle' }; return icons[toast.value.type] || 'info-circle'; };
</script>
