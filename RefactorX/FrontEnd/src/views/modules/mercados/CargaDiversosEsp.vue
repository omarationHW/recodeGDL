<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-import" />
      </div>
      <div class="module-view-info">
        <h1>Carga Diversos Especial</h1>
        <p>Mercados - Carga Especial de Pagos Realizados por Diversos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-danger"
          @click="cerrar"
        >
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Adeudos
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row align-items-end">
            <div class="col-md-4 mb-3">
              <label class="municipal-form-label">Fecha de Pago *</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="fechaPago"
                :disabled="loading"
              />
            </div>
            <div class="col-md-8 mb-3">
              <div class="d-flex gap-2">
                <button
                  class="btn-municipal-primary"
                  @click="buscarAdeudos"
                  :disabled="!fechaPago || loading"
                >
                  <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                  <font-awesome-icon icon="search" v-if="!loading" />
                  Buscar
                </button>
                <button
                  class="btn-municipal-success"
                  @click="cargarPagos"
                  :disabled="!hayPagosValidos || loading"
                >
                  <font-awesome-icon icon="save" />
                  Grabar Pagos
                </button>
                <button
                  class="btn-municipal-secondary"
                  @click="limpiar"
                  :disabled="loading"
                >
                  <font-awesome-icon icon="eraser" />
                  Limpiar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Adeudos -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Adeudos Encontrados
            <span v-if="adeudos.length > 0" class="badge bg-primary ms-2">{{ adeudos.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Loading Spinner -->
          <div v-if="loading" class="text-center py-4">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
          </div>

          <!-- Tabla -->
          <div v-else-if="adeudos.length > 0" class="table-responsive">
            <table class="municipal-table table-sm">
              <thead>
                <tr>
                  <th>Fecha</th>
                  <th>Rec</th>
                  <th>Caja</th>
                  <th>Oper</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Renta</th>
                  <th>Ofn</th>
                  <th>Mer</th>
                  <th>Cat</th>
                  <th>Sec</th>
                  <th>Local</th>
                  <th>Let</th>
                  <th>Partida</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in adeudos" :key="idx">
                  <td>{{ formatDate(row.fecha) }}</td>
                  <td>{{ row.rec }}</td>
                  <td>{{ row.caja }}</td>
                  <td>{{ row.oper }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ row.mes }}</td>
                  <td>{{ formatCurrency(row.renta) }}</td>
                  <td>{{ row.ofn }}</td>
                  <td>{{ row.mer }}</td>
                  <td>{{ row.cat }}</td>
                  <td>{{ row.sec }}</td>
                  <td>{{ row.local }}</td>
                  <td>{{ row.let }}</td>
                  <td>
                    <input
                      type="text"
                      class="form-control form-control-sm"
                      v-model="pagos[idx].partida"
                      placeholder="Partida"
                      maxlength="20"
                    />
                  </td>
                </tr>
              </tbody>
            </table>

            <div class="alert alert-info mt-3">
              <font-awesome-icon icon="info-circle" />
              <strong>Nota:</strong> Solo se grabarán los pagos con número de partida distinto de vacío o cero.
            </div>
          </div>

          <!-- Sin resultados -->
          <div v-else class="text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
            <p>No hay adeudos para mostrar. Seleccione una fecha y presione "Buscar".</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import Swal from 'sweetalert2';
import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faFileImport, faSearch, faList, faSave, faTimes,
  faQuestionCircle, faEraser, faInfoCircle, faInbox
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

library.add(
  faFileImport, faSearch, faList, faSave, faTimes,
  faQuestionCircle, faEraser, faInfoCircle, faInbox
);

const router = useRouter();
const { showLoading, hideLoading } = useGlobalLoading();

// Helper para mostrar toasts
const showToast = (icon, title) => {
  Swal.fire({
    toast: true,
    position: 'top-end',
    icon,
    title,
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true
  });
};

// Estados
const loading = ref(false);
const fechaPago = ref('');
const adeudos = ref([]);
const pagos = ref([]);

// Computed para verificar si hay pagos válidos
const hayPagosValidos = computed(() => {
  return pagos.value.some(p => p.partida && p.partida.trim() !== '' && p.partida !== '0');
});

// Buscar adeudos
async function buscarAdeudos() {
  if (!fechaPago.value) {
    showToast('Seleccione una fecha de pago', 'warning');
    return;
  }

  loading.value = true;
  adeudos.value = [];
  pagos.value = [];

  try {
    showLoading('Buscando adeudos', 'Por favor espere');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_adeudos_diversos_esp',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_fecha_pago', Valor: fechaPago.value }
        ]
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      adeudos.value = response.data.eResponse.data.result;
      // Inicializar array de pagos con partidas vacías
      pagos.value = adeudos.value.map(() => ({ partida: '' }));

      if (adeudos.value.length === 0) {
        showToast('No se encontraron adeudos para esta fecha', 'info');
      } else {
        showToast(`Se encontraron ${adeudos.value.length} adeudos`, 'success');
      }
    } else {
      adeudos.value = [];
      showToast('No se encontraron adeudos', 'info');
    }
  } catch (error) {
    console.error('Error al buscar adeudos:', error);
    showToast('Error al buscar adeudos', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Cargar pagos
async function cargarPagos() {
  // Filtrar solo pagos con partida válida
  const pagosValidos = adeudos.value
    .map((row, idx) => ({
      ...row,
      partida: pagos.value[idx].partida
    }))
    .filter(p => p.partida && p.partida.trim() !== '' && p.partida !== '0');

  if (pagosValidos.length === 0) {
    showToast('No hay pagos válidos para grabar', 'warning');
    return;
  }

  const result = await Swal.fire({
    title: '¿Grabar pagos?',
    text: `Se grabarán ${pagosValidos.length} pagos`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, grabar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  loading.value = true;

  try {
    showLoading('Cargando pagos', 'Por favor espere');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cargar_pagos_diversos_esp',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_pagos', Valor: JSON.stringify(pagosValidos) },
          { Nombre: 'p_id_usuario', Valor: 1 }, // TODO: Obtener de sesión
          { Nombre: 'p_fecha_pago', Valor: fechaPago.value }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      showToast(`${pagosValidos.length} pagos cargados correctamente`, 'success');
      // Recargar adeudos
      await buscarAdeudos();
    }
  } catch (error) {
    console.error('Error al cargar pagos:', error);
    showToast('Error al cargar pagos', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Limpiar
function limpiar() {
  fechaPago.value = '';
  adeudos.value = [];
  pagos.value = [];
}

// Formato de fecha
function formatDate(dateStr) {
  if (!dateStr) return '';
  const date = new Date(dateStr);
  return date.toLocaleDateString('es-MX');
}

// Formato de moneda
function formatCurrency(value) {
  if (!value && value !== 0) return '$0.00';
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value);
}

// Mostrar ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Carga Diversos Especial',
    html: `
      <div style="text-align: left;">
        <h6>Instrucciones:</h6>
        <ol>
          <li>Seleccione la fecha de pago</li>
          <li>Presione "Buscar" para obtener los adeudos</li>
          <li>Ingrese el número de partida para cada pago que desea grabar</li>
          <li>Solo se grabarán los pagos con partida válida (no vacía ni cero)</li>
          <li>Presione "Grabar Pagos" para registrar los pagos</li>
        </ol>
        <p><strong>Nota:</strong> Los pagos se asociarán automáticamente con el local correspondiente.</p>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}

// Cerrar
function cerrar() {
  router.push('/');
}
</script>

