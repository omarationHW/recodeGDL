<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="user-shield" />
      </div>
      <div class="module-view-info">
        <h1>Autorizar Fecha de Ingreso</h1>
        <p>Mercados - Mantenimiento de Autorizaciones de Fechas</p>
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
        
        <button class="btn-municipal-primary" @click="abrirModal(null)" :disabled="loading">
          <font-awesome-icon icon="plus" />
          Nueva Autorización
        </button>
        <button class="btn-municipal-secondary" @click="cargarDatos" :disabled="loading">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        </div>
    </div>

    <div class="module-view-content">
      <!-- Lista de Autorizaciones -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Fechas Autorizadas ({{ fechasPaginadas.length }} de {{ fechas.length }})
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
          <div v-else>
            <div class="table-responsive">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Fecha Ingreso</th>
                    <th>Permiso</th>
                    <th>Fecha Límite</th>
                    <th>Usuario Permiso</th>
                    <th>Comentarios</th>
                    <th>Actualización</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="item in fechasPaginadas" :key="`${item.fecha_ingreso}-${item.oficina}`">
                    <td>{{ formatDate(item.fecha_ingreso) }}</td>
                    <td>
                      <span :class="item.autorizar === 'S' ? 'badge bg-success' : 'badge bg-danger'">
                        {{ item.autorizar === 'S' ? 'AUTORIZAR' : 'BLOQUEAR' }}
                      </span>
                    </td>
                    <td>{{ formatDate(item.fecha_limite) }}</td>
                    <td>{{ item.nombre }}</td>
                    <td>{{ item.comentarios }}</td>
                    <td>{{ formatDateTime(item.actualizacion) }}</td>

                    <td>
                      <div class="button-group button-group-sm">
                        <button class="btn-municipal-primary btn-sm" @click.stop="abrirModal(item)" title="Editar">
                          <font-awesome-icon icon="edit" />
                        </button>
                      </div>
                    </td>
            
                  </tr>
                  <tr v-if="fechas.length === 0">
                    <td colspan="7" class="text-center text-muted">
                      No hay fechas autorizadas
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Controles de Paginación -->
            <div v-if="fechas.length > 0" class="pagination-controls">
              <div class="pagination-info">
                <span class="text-muted">
                  Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                  a {{ Math.min(currentPage * itemsPerPage, fechas.length) }}
                  de {{ fechas.length }} registros
                </span>
              </div>

              <div class="pagination-size">
                <label class="municipal-form-label me-2">Registros por página:</label>
                <select class="municipal-form-control form-control-sm" v-model.number="itemsPerPage"
                  style="width: auto; display: inline-block;">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                </select>
              </div>

              <div class="pagination-buttons">
                <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1"
                  title="Primera página">
                  <font-awesome-icon icon="angle-double-left" />
                </button>

                <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)"
                  :disabled="currentPage === 1" title="Página anterior">
                  <font-awesome-icon icon="angle-left" />
                </button>

                <button v-for="page in visiblePages" :key="page" class="btn-sm"
                  :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                  @click="goToPage(page)">
                  {{ page }}
                </button>

                <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)"
                  :disabled="currentPage === totalPages" title="Página siguiente">
                  <font-awesome-icon icon="angle-right" />
                </button>

                <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)"
                  :disabled="currentPage === totalPages" title="Última página">
                  <font-awesome-icon icon="angle-double-right" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para Crear/Editar -->
    <div v-if="showModal" class="modal-overlay" @click.self="cerrarModal">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon icon="calendar-check" />
              {{ editing ? 'Modificar Autorización' : 'Nueva Autorización' }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarAutorizacion">
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Fecha Ingreso <span class="required">*</span></label>
                  <input type="date" class="municipal-form-control" v-model="form.fecha_ingreso" required
                    :disabled="editing" />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Permiso <span class="required">*</span></label>
                  <select class="municipal-form-control" v-model="form.autorizar" required>
                    <option value="S">✓ AUTORIZAR FECHA</option>
                    <option value="N">✗ BLOQUEAR FECHA</option>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Fecha Límite <span class="required">*</span></label>
                  <input type="date" class="municipal-form-control" v-model="form.fecha_limite" required />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Usuario con Permiso <span class="required">*</span></label>
                  <select class="municipal-form-control" v-model.number="form.id_usupermiso" required>
                    <option value="">Seleccione...</option>
                    <option v-for="user in usuarios" :key="user.id_usuario" :value="user.id_usuario">
                      {{ user.nombre }} ({{ user.usuario }})
                    </option>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="col-12 mb-3">
                  <label class="municipal-form-label">Comentarios</label>
                  <textarea class="municipal-form-control" v-model="form.comentarios" rows="4" @input="toUpperCase"
                    style="text-transform: uppercase;"></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button class="btn-municipal-secondary" type="button" @click="cerrarModal" :disabled="loading">
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
            <button class="btn-municipal-primary" type="button" @click="guardarAutorizacion" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              <font-awesome-icon icon="save" v-if="!loading" />
              {{ editing ? 'Actualizar' : 'Guardar' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'AutCargaPagosMtto'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - AutCargaPagosMtto'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'AutCargaPagosMtto'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - AutCargaPagosMtto'" @close="showDocumentacion = false" />
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
import { ref, computed, watch, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import Swal from 'sweetalert2';
import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faUserShield, faCalendarCheck, faList, faSave, faTimes,
  faQuestionCircle, faSyncAlt, faEdit, faPlus,
  faAngleDoubleLeft, faAngleLeft, faAngleRight, faAngleDoubleRight
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


library.add(
  faUserShield, faCalendarCheck, faList, faSave, faTimes,
  faQuestionCircle, faSyncAlt, faEdit, faPlus,
  faAngleDoubleLeft, faAngleLeft, faAngleRight, faAngleDoubleRight
);

const router = useRouter();
const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();

// Estados
const loading = ref(false);
const usuarios = ref([]);
const fechas = ref([]);
const editing = ref(false);
const showModal = ref(false);

// Paginación
const currentPage = ref(1);
const itemsPerPage = ref(10);

// Formulario
const form = ref({
  fecha_ingreso: '',
  oficina: 1, // TODO: Obtener de sesión
  autorizar: 'S',
  fecha_limite: '',
  id_usupermiso: '',
  comentarios: ''
});

// Computed
const totalPages = computed(() => {
  const pages = Math.ceil(fechas.value.length / itemsPerPage.value);
  return pages > 0 ? pages : 1;
});

const fechasPaginadas = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value;
  const end = start + itemsPerPage.value;
  return fechas.value.slice(start, end);
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

// Watch itemsPerPage para resetear página
watch(itemsPerPage, () => {
  currentPage.value = 1;
});

// Función para ir a una página específica
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return;
  currentPage.value = page;
};

// Cargar datos iniciales
onMounted(() => {
  cargarUsuarios();
  cargarDatos();
});

// Abrir modal
function abrirModal(item) {
  if (item) {
    // Editar
    form.value = {
      fecha_ingreso: item.fecha_ingreso?.split('T')[0] || item.fecha_ingreso,
      oficina: item.oficina,
      autorizar: item.autorizar,
      fecha_limite: item.fecha_limite?.split('T')[0] || item.fecha_limite,
      id_usupermiso: item.id_usupermiso,
      comentarios: item.comentarios || ''
    };
    editing.value = true;
  } else {
    // Nuevo
    form.value = {
      fecha_ingreso: '',
      oficina: 1,
      autorizar: 'S',
      fecha_limite: '',
      id_usupermiso: '',
      comentarios: ''
    };
    editing.value = false;
  }
  showModal.value = true;
}

// Cerrar modal
function cerrarModal() {
  showModal.value = false;
  form.value = {
    fecha_ingreso: '',
    oficina: 1,
    autorizar: 'S',
    fecha_limite: '',
    id_usupermiso: '',
    comentarios: ''
  };
  editing.value = false;
}

// Cargar usuarios con permiso
async function cargarUsuarios() {
  try {
    showLoading('Cargando usuarios', 'Por favor espere');
    const p_oficina = 1; // TODO: Obtener de sesión

    const response = await apiService.execute(
          'sp_get_users_with_permission',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(p_oficina), tipo: 'integer' }
        ],
          '',
          null,
          'publico'
        );

    if (response.success && response.data?.result) {
      usuarios.value = response.data.result;
    }
  } catch (error) {
    console.error('Error al cargar usuarios:', error);
    showToast('Error al cargar usuarios con permiso', 'error');
  } finally {
    hideLoading();
  }
}

// Cargar fechas autorizadas
async function cargarDatos() {
  loading.value = true;

  try {
    showLoading('Cargando fechas autorizadas', 'Por favor espere');
    const p_oficina = 1; // TODO: Obtener de sesión

    const response = await apiService.execute(
          'sp_list_autcargapag',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(p_oficina), tipo: 'integer' }
        ],
          '',
          null,
          'publico'
        );

    if (response.success && response.data?.result) {
      fechas.value = response.data.result;
    } else {
      fechas.value = [];
    }
  } catch (error) {
    console.error('Error al cargar fechas:', error);
    showToast('Error al cargar fechas autorizadas', 'error');
    fechas.value = [];
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Guardar autorización (agregar o modificar)
async function guardarAutorizacion() {
  loading.value = true;

  try {
    showLoading('Guardando autorización', 'Por favor espere');
    const operacion = editing.value ? 'sp_update_autcargapag' : 'sp_insert_autcargapag';
    const ahora = new Date().toISOString();

    const response = await apiService.execute(
      operacion,
      'mercados',
      [
        { nombre: 'p_fecha_ingreso', valor: form.value.fecha_ingreso, tipo: 'date' },
        { nombre: 'p_oficina', valor: parseInt(form.value.oficina), tipo: 'integer' },
        { nombre: 'p_autorizar', valor: form.value.autorizar, tipo: 'varchar' },
        { nombre: 'p_fecha_limite', valor: form.value.fecha_limite, tipo: 'date' },
        { nombre: 'p_id_usupermiso', valor: parseInt(form.value.id_usupermiso), tipo: 'integer' },
        { nombre: 'p_comentarios', valor: form.value.comentarios.toUpperCase(), tipo: 'text' },
        { nombre: 'p_id_usuario', valor: 1, tipo: 'integer' }, // TODO: Obtener de sesión
        { nombre: 'p_actualizacion', valor: ahora, tipo: 'timestamp' }
      ],
      '',
      null,
      'publico'
    );

    if (response.success) {
      showToast(editing.value ? 'Autorización actualizada correctamente' : 'Autorización creada correctamente', 'success');
      cerrarModal();
      await cargarDatos();
    }
  } catch (error) {
    console.error('Error al guardar autorización:', error);
    showToast('Error al guardar autorización: ' + error.message, 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Convertir a mayúsculas
function toUpperCase() {
  form.value.comentarios = form.value.comentarios.toUpperCase();
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
    title: 'Ayuda - Autorizar Fecha de Ingreso',
    html: `
      <div style="text-align: left;">
        <h6>Instrucciones:</h6>
        <ol>
          <li>Haga clic en "Nueva Autorización" para crear una autorización de fecha</li>
          <li>Seleccione si desea AUTORIZAR o BLOQUEAR la fecha</li>
          <li>Indique la fecha límite de validez de la autorización</li>
          <li>Seleccione el usuario que tendrá el permiso</li>
          <li>Agregue comentarios explicativos (se convertirán a mayúsculas)</li>
          <li>Puede editar autorizaciones existentes haciendo clic en "Editar" en la tabla</li>
          <li>Use la paginación para navegar entre registros</li>
        </ol>
        <p><strong>Nota:</strong> La fecha de ingreso no puede modificarse una vez creada.</p>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}</script>
