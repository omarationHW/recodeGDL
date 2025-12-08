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
        >
          <font-awesome-icon icon="plus" />
          Agregar
        </button>
        <button
          class="btn-municipal-primary"
          @click="abrirModalEditar"
          :disabled="!selectedRow"
        >
          <font-awesome-icon icon="edit" />
          Modificar
        </button>
        <button
          class="btn-municipal-primary"
          @click="cargarDatos"
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
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Lista de Autorizaciones de Carga
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="rows.length > 0">
              {{ rows.length }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body">
          <!-- Tabla -->
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
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
                  v-for="(row, index) in paginatedRows"
                  :key="`${row.fecha_ingreso}-${row.oficina}`"
                  :class="{ 'table-row-selected': selectedRow && selectedRow.fecha_ingreso === row.fecha_ingreso && selectedRow.oficina === row.oficina }"
                  @click="seleccionarFila(row)"
                  class="row-hover"
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
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay autorizaciones registradas</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
              de {{ totalRecords }} registros
            </div>
            <div class="pagination-controls">
              <label class="me-2">Registros por página:</label>
              <select v-model.number="itemsPerPage" class="form-select form-select-sm">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
            <div class="pagination-buttons">
              <button @click="goToPage(1)" :disabled="currentPage === 1" title="Primera página">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button @click="goToPage(currentPage - 1)" :disabled="currentPage === 1" title="Página anterior">
                <font-awesome-icon icon="angle-left" />
              </button>
              <button v-for="page in visiblePages" :key="page"
                :class="page === currentPage ? 'active' : ''"
                @click="goToPage(page)">
                {{ page }}
              </button>
              <button @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages" title="Página siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button @click="goToPage(totalPages)" :disabled="currentPage === totalPages" title="Última página">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
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
    <Modal
      v-if="showModal"
      :show="showModal"
      :title="modalMode === 'add' ? 'Agregar Autorización' : 'Modificar Autorización'"
      size="lg"
      @close="cerrarModal">
      <!-- <template #body> -->
        <form @submit.prevent="guardarAutorizacion">
          <div class="row">
            <div class="col-md-6 mb-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar" class="me-2" />
                Fecha Ingreso <span class="text-danger">*</span>
              </label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="form.fecha_ingreso"
                required
                :disabled="modalMode === 'edit'"
              />
            </div>
            <div class="col-md-6 mb-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="building" class="me-2" />
                Oficina <span class="text-danger">*</span>
              </label>
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
              <label class="municipal-form-label">
                <font-awesome-icon icon="check-circle" class="me-2" />
                Autorizar <span class="text-danger">*</span>
              </label>
              <select class="municipal-form-control" v-model="form.autorizar" required>
                <option value="S">Sí</option>
                <option value="N">No</option>
              </select>
            </div>
            <div class="col-md-6 mb-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-check" class="me-2" />
                Fecha Límite <span class="text-danger">*</span>
              </label>
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
              <label class="municipal-form-label">
                <font-awesome-icon icon="user" class="me-2" />
                Usuario con Permiso (ID) <span class="text-danger">*</span>
              </label>
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
              <label class="municipal-form-label">
                <font-awesome-icon icon="comment" class="me-2" />
                Comentarios
              </label>
              <textarea
                class="municipal-form-control"
                v-model="form.comentarios"
                rows="4"
              ></textarea>
            </div>
          </div>

          <div class="alert alert-info d-flex align-items-center" v-if="modalMode === 'edit'">
            <font-awesome-icon icon="info-circle" class="me-2" />
            <small>Los campos Fecha Ingreso y Oficina no se pueden modificar en autorizaciones existentes.</small>
          </div>
        </form>
      <!-- </template> -->

      <template #footer>
        <button class="btn-municipal-secondary" type="button" @click="cerrarModal">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-success" type="button" @click="guardarAutorizacion">
          <font-awesome-icon icon="save" />
          Guardar
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import Swal from 'sweetalert2';
import Modal from '@/components/common/Modal.vue';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faClipboardCheck, faList, faPlus, faEdit, faSave, faTimes,
  faQuestionCircle, faSyncAlt, faInbox, faCalendar, faBuilding,
  faCheckCircle, faCalendarCheck, faUser, faComment, faInfoCircle,
  faAngleDoubleLeft, faAngleLeft, faAngleRight, faAngleDoubleRight
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

library.add(
  faClipboardCheck, faList, faPlus, faEdit, faSave, faTimes,
  faQuestionCircle, faSyncAlt, faInbox, faCalendar, faBuilding,
  faCheckCircle, faCalendarCheck, faUser, faComment, faInfoCircle,
  faAngleDoubleLeft, faAngleLeft, faAngleRight, faAngleDoubleRight
);

const router = useRouter();
const { withLoading } = useGlobalLoading();
const { showToast } = useToast();

// Estados
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

// Paginación
const currentPage = ref(1);
const itemsPerPage = ref(25);
const totalRecords = computed(() => rows.value.length);

const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value);
});

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value;
  const end = start + itemsPerPage.value;
  return rows.value.slice(start, end);
});

const visiblePages = computed(() => {
  const pages = [];
  const maxVisible = 5;
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2));
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1);

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1);
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i);
  }

  return pages;
});

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return;
  currentPage.value = page;
  selectedRow.value = null;
};

// Cargar datos iniciales
onMounted(() => {
  cargarDatos();
});

// Cargar autorizaciones
async function cargarDatos() {
  await withLoading(async () => {
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
        if (rows.value.length > 0) {
          showToast(`Se cargaron ${rows.value.length} autorizaciones`, 'success');
        } else {
          showToast('No se encontraron autorizaciones registradas', 'info');
        }
      } else {
        rows.value = [];
        showToast('No se encontraron autorizaciones', 'info');
      }
    } catch (error) {
      console.error('Error al cargar autorizaciones:', error);
      showToast('Error al cargar autorizaciones', 'error');
      rows.value = [];
    }
  }, 'Cargando autorizaciones...', 'Por favor espere');
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
    showToast('Seleccione una autorización', 'warning');
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
  await withLoading(async () => {
    try {
      const operacion = modalMode.value === 'add' ? 'sp_autcargapag_createv1' : 'sp_autcargapag_update';

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
        showToast(
          modalMode.value === 'add' ? 'Autorización agregada exitosamente' : 'Autorización modificada exitosamente',
          'success'
        );
        cerrarModal();
        await cargarDatos();
      } else {
        showToast(response.data?.eResponse?.message || 'Error al guardar autorización', 'error');
      }
    } catch (error) {
      console.error('Error al guardar autorización:', error);
      showToast('Error al guardar autorización', 'error');
    }
  }, modalMode.value === 'add' ? 'Guardando autorización...' : 'Actualizando autorización...', 'Por favor espere');
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
