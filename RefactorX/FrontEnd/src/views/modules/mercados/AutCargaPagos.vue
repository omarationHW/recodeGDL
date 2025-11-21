<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-check" />
      </div>
      <div class="module-view-info">
        <h1>Autorización Carga de Pagos</h1>
        <p>Mercados - Gestión de Autorizaciones para Carga de Pagos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-primary"
          @click="abrirModalNuevo"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Agregar
        </button>
        <button
          class="btn-municipal-primary"
          @click="abrirModalEditar"
          :disabled="!selectedRow || loading"
        >
          <font-awesome-icon icon="edit" />
          Modificar
        </button>
        <button
          class="btn-municipal-primary"
          @click="cargarDatos"
          :disabled="loading"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
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
      <!-- Tabla de Autorizaciones -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Lista de Autorizaciones de Carga
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
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Fecha Ingreso</th>
                  <th>Oficina</th>
                  <th>Autorizar</th>
                  <th>Fecha Límite</th>
                  <th>Usuario Permiso</th>
                  <th>Usuario Modificó</th>
                  <th>Actualización</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(row, index) in rows"
                  :key="`${row.fecha_ingreso}-${row.oficina}`"
                  :class="{ 'table-active': selectedRow && selectedRow.fecha_ingreso === row.fecha_ingreso && selectedRow.oficina === row.oficina }"
                  @click="seleccionarFila(row)"
                  style="cursor: pointer;"
                >
                  <td>{{ formatDate(row.fecha_ingreso) }}</td>
                  <td>{{ row.oficina }}</td>
                  <td>
                    <span :class="row.autorizar === 'S' ? 'badge bg-success' : 'badge bg-danger'">
                      {{ row.autorizar === 'S' ? 'Sí' : 'No' }}
                    </span>
                  </td>
                  <td>{{ formatDate(row.fecha_limite) }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.usuario }}</td>
                  <td>{{ formatDateTime(row.actualizacion) }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    No hay autorizaciones registradas
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Comentarios de la Fila Seleccionada -->
          <div v-if="selectedRow" class="mt-3">
            <label class="municipal-form-label">Comentarios:</label>
            <textarea
              class="municipal-form-control"
              rows="3"
              :value="selectedRow.comentarios"
              readonly
            ></textarea>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para Agregar/Modificar -->
    <div v-if="showModal" class="modal fade show d-block" tabindex="-1" style="background-color: rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon :icon="modalMode === 'add' ? 'plus' : 'edit'" />
              {{ modalMode === 'add' ? 'Agregar Autorización' : 'Modificar Autorización' }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarAutorizacion">
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Fecha Ingreso *</label>
                  <input
                    type="date"
                    class="municipal-form-control"
                    v-model="form.fecha_ingreso"
                    required
                    :disabled="modalMode === 'edit'"
                  />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Oficina *</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="form.oficina"
                    required
                    :disabled="modalMode === 'edit'"
                  />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Autorizar *</label>
                  <select class="municipal-form-control" v-model="form.autorizar" required>
                    <option value="S">Sí</option>
                    <option value="N">No</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Fecha Límite *</label>
                  <input
                    type="date"
                    class="municipal-form-control"
                    v-model="form.fecha_limite"
                    required
                  />
                </div>
              </div>
              <div class="row">
                <div class="col-md-12 mb-3">
                  <label class="municipal-form-label">Usuario con Permiso (ID) *</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="form.id_usupermiso"
                    required
                  />
                </div>
              </div>
              <div class="row">
                <div class="col-md-12 mb-3">
                  <label class="municipal-form-label">Comentarios</label>
                  <textarea
                    class="municipal-form-control"
                    v-model="form.comentarios"
                    rows="4"
                  ></textarea>
                </div>
              </div>
              <div class="modal-footer">
                <button class="btn-municipal-success" type="submit" :disabled="loading">
                  <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                  <font-awesome-icon icon="save" v-if="!loading" />
                  Guardar
                </button>
                <button class="btn-municipal-secondary" type="button" @click="cerrarModal">
                  <font-awesome-icon icon="times" />
                  Cancelar
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import Swal from 'sweetalert2';
import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faClipboardCheck, faList, faPlus, faEdit, faSave, faTimes,
  faQuestionCircle, faSyncAlt
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

library.add(
  faClipboardCheck, faList, faPlus, faEdit, faSave, faTimes,
  faQuestionCircle, faSyncAlt
);

const router = useRouter();

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
const rows = ref([]);
const selectedRow = ref(null);
const showModal = ref(false);
const modalMode = ref('add'); // 'add' o 'edit'

// Formulario
const form = ref({
  fecha_ingreso: '',
  oficina: null,
  autorizar: 'S',
  fecha_limite: '',
  id_usupermiso: null,
  comentarios: ''
});

// Cargar datos iniciales
onMounted(() => {
  cargarDatos();
});

// Cargar autorizaciones
async function cargarDatos() {
  loading.value = true;
  selectedRow.value = null;

  try {
    // TODO: Obtener oficina del usuario de sesión
    const p_oficina = null; // Si es null, trae todas las oficinas

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_autcargapag_list',
        Base: 'mercados',
        Parametros: p_oficina !== null ? [
          { Nombre: 'p_oficina', Valor: parseInt(p_oficina) }
        ] : []
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      rows.value = response.data.eResponse.data.result;
    } else {
      rows.value = [];
    }
  } catch (error) {
    console.error('Error al cargar autorizaciones:', error);
    showToast('error', 'Error al cargar autorizaciones');
    rows.value = [];
  } finally {
    loading.value = false;
  }
}

// Seleccionar fila
function seleccionarFila(row) {
  selectedRow.value = row;
}

// Abrir modal para nuevo
function abrirModalNuevo() {
  modalMode.value = 'add';
  form.value = {
    fecha_ingreso: new Date().toISOString().split('T')[0],
    oficina: null,
    autorizar: 'S',
    fecha_limite: '',
    id_usupermiso: null,
    comentarios: ''
  };
  showModal.value = true;
}

// Abrir modal para editar
function abrirModalEditar() {
  if (!selectedRow.value) {
    showToast('warning', 'Seleccione una autorización');
    return;
  }

  modalMode.value = 'edit';
  form.value = {
    fecha_ingreso: selectedRow.value.fecha_ingreso?.split('T')[0] || selectedRow.value.fecha_ingreso,
    oficina: selectedRow.value.oficina,
    autorizar: selectedRow.value.autorizar,
    fecha_limite: selectedRow.value.fecha_limite?.split('T')[0] || selectedRow.value.fecha_limite,
    id_usupermiso: selectedRow.value.id_usupermiso,
    comentarios: selectedRow.value.comentarios || ''
  };
  showModal.value = true;
}

// Cerrar modal
function cerrarModal() {
  showModal.value = false;
}

// Guardar autorización (agregar o modificar)
async function guardarAutorizacion() {
  loading.value = true;

  try {
    const operacion = modalMode.value === 'add' ? 'sp_autcargapag_create' : 'sp_autcargapag_update';

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_fecha_ingreso', Valor: form.value.fecha_ingreso },
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
          { Nombre: 'p_autorizar', Valor: form.value.autorizar },
          { Nombre: 'p_fecha_limite', Valor: form.value.fecha_limite },
          { Nombre: 'p_id_usupermiso', Valor: parseInt(form.value.id_usupermiso) },
          { Nombre: 'p_comentarios', Valor: form.value.comentarios || '' },
          { Nombre: 'p_id_usuario', Valor: 1 } // TODO: Obtener de sesión
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      showToast('success', modalMode.value === 'add' ? 'Autorización agregada' : 'Autorización modificada');
      cerrarModal();
      await cargarDatos();
    }
  } catch (error) {
    console.error('Error al guardar autorización:', error);
    showToast('error', 'Error al guardar autorización');
  } finally {
    loading.value = false;
  }
}

// Formato de fecha
function formatDate(dateStr) {
  if (!dateStr) return '';
  const date = new Date(dateStr);
  return date.toLocaleDateString('es-MX');
}

// Formato de fecha y hora
function formatDateTime(dateStr) {
  if (!dateStr) return '';
  const date = new Date(dateStr);
  return date.toLocaleString('es-MX');
}

// Mostrar ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Autorización Carga de Pagos',
    html: `
      <div style="text-align: left;">
        <h6>Instrucciones:</h6>
        <ol>
          <li>La lista muestra todas las autorizaciones de carga de pagos</li>
          <li>Haga clic en una fila para seleccionarla y ver sus comentarios</li>
          <li>Use "Agregar" para crear una nueva autorización</li>
          <li>Seleccione una fila y use "Modificar" para editarla</li>
          <li>Use "Actualizar" para recargar los datos</li>
          <li>La columna "Autorizar" indica si la carga está autorizada (Sí/No)</li>
          <li>La "Fecha Límite" indica hasta cuándo es válida la autorización</li>
        </ol>
        <p><strong>Nota:</strong> Los campos Fecha Ingreso y Oficina no se pueden modificar en autorizaciones existentes.</p>
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

<style scoped>
.table-active {
  background-color: #e6f7ff !important;
}

.badge {
  padding: 0.35em 0.65em;
  font-size: 0.85em;
}
</style>
