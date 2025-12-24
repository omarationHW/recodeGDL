<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Captura por Mercado</h1>
        <p>Mercados - Detalle de Pagos Capturados por Mercado</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        </div>
    </div>

    <div class="module-view-content">
      <!-- Selección de Mercado -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Seleccionar Mercado
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-6 mb-3">
              <label class="municipal-form-label">Mercado *</label>
              <select class="municipal-form-control" v-model="selectedMercado" @change="buscarPagos">
                <option value="">Seleccione un mercado...</option>
                <option v-for="m in mercados" :key="m.id_mercado" :value="m">
                  {{ m.oficina }}-{{ m.num_mercado }} | {{ m.nombre_mercado }}
                </option>
              </select>
            </div>
            <div class="col-md-6 mb-3" v-if="selectedMercado">
              <label class="municipal-form-label">Información</label>
              <div class="p-2 bg-light rounded">
                <strong>Oficina:</strong> {{ selectedMercado.oficina }} |
                <strong>Mercado:</strong> {{ selectedMercado.num_mercado }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Pagos Capturados
            <span v-if="pagos.length > 0" class="badge bg-primary ms-2">{{ pagos.length }}</span>
          </h5>
          <button v-if="pagos.length > 0" class="btn-municipal-primary btn-sm ms-auto" @click="buscarPagos">
            <font-awesome-icon icon="sync" />
            Actualizar
          </button>
        </div>
        <div class="municipal-card-body">
          <div v-if="loading" class="text-center py-4">
            <div class="spinner-border text-primary" role="status"></div>
          </div>

          <div v-else-if="pagos.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Datos Local</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Fecha Pago</th>
                  <th>Oficina</th>
                  <th>Caja</th>
                  <th>Oper.</th>
                  <th>Importe</th>
                  <th>Folio</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="`${pago.id_local}-${pago.axo}-${pago.periodo}`">
                  <td>{{ pago.id_local }}</td>
                  <td>{{ pago.datoslocal }}</td>
                  <td>{{ pago.axo }}</td>
                  <td>{{ pago.periodo }}</td>
                  <td>{{ pago.fecha_pago }}</td>
                  <td>{{ pago.oficina_pago }}</td>
                  <td>{{ pago.caja_pago }}</td>
                  <td>{{ pago.operacion_pago }}</td>
                  <td>{{ formatCurrency(pago.importe_pago) }}</td>
                  <td>{{ pago.folio }}</td>
                  <td>{{ pago.usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
            <p v-if="selectedMercado">No hay pagos registrados para este mercado</p>
            <p v-else>Seleccione un mercado para ver los pagos</p>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'ConsCapturaMerc'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - ConsCapturaMerc'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'ConsCapturaMerc'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - ConsCapturaMerc'" @close="showDocumentacion = false" />
</template>

<script setup>

// Helpers de confirmación SweetAlert
const confirmarAccion = async (titulo, texto, confirmarTexto = 'Sí, continuar') => {
  const result = await Swal.fire({
    title: titulo,
    text: texto,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#d33',
    confirmButtonText: confirmarTexto,
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}

const mostrarConfirmacionEliminar = async (texto) => {
  const result = await Swal.fire({
    title: '¿Eliminar registro?',
    text: texto,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#3085d6',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}
import apiService from '@/services/apiService';
import { ref, onMounted } from 'vue';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const router = useRouter();

const loading = ref(false);
const mercados = ref([]);
const selectedMercado = ref(null);
const pagos = ref([]);

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0);
};

const showToast = (type, message) => {
  Swal.fire({ toast: true, position: 'top-end', icon: type, title: message, showConfirmButton: false, timer: 3000 });
};async function cargarMercados() {
  try {
    const response = await apiService.execute(
          'sp_cons_captura_merc_get_mercados',
          'mercados',
          [],
          '',
          null,
          'publico'
        );

    if (response.success) {
      mercados.value = response.data.result || [];
    }
  } catch (error) {
    console.error('Error cargando mercados:', error);
    showToast('Error al cargar mercados', 'error');
  }
}

async function buscarPagos() {
  if (!selectedMercado.value) {
    pagos.value = [];
    return;
  }

  loading.value = true;
  pagos.value = [];

  try {
    const response = await apiService.execute(
          'sp_cons_captura_merc_get_pagos',
          'mercados',
          [
          { nombre: 'p_oficina', valor: selectedMercado.value.oficina, tipo: 'integer' },
          { nombre: 'p_num_mercado', valor: selectedMercado.value.num_mercado, tipo: 'integer' }
        ],
          '',
          null,
          'publico'
        );

    if (response.success) {
      pagos.value = response.data.result || [];
      if (pagos.value.length === 0) {
        showToast('No se encontraron pagos', 'info');
      }
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al buscar pagos', 'error');
  } finally {
    loading.value = false;
  }
}


// Ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Consulta de Captura por Mercado',
    html: `
      <div style="text-align: left;">
        <h6>Funcionalidad del mÃ³dulo:</h6>
        <p>Este mÃ³dulo permite consultar las capturas realizadas por mercado.</p>
        <h6>Instrucciones:</h6>
        <ol>
          <li>Seleccione la recaudadora y mercado
          <li>Indique el perÃ­odo a consultar
          <li>Los resultados incluyen el detalle de todas las capturas</li>
        </ol>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}

onMounted(() => cargarMercados());
</script>
