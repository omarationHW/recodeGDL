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
      <!-- Formulario de Autorización -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="calendar-check" />
            {{ editing ? 'Modificar Autorización' : 'Nueva Autorización' }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="guardarAutorizacion">
            <div class="row">
              <div class="col-md-6 mb-3">
                <label class="municipal-form-label">Fecha Ingreso *</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="form.fecha_ingreso"
                  required
                  :disabled="editing"
                />
              </div>
              <div class="col-md-6 mb-3">
                <label class="municipal-form-label">Permiso *</label>
                <select class="municipal-form-control" v-model="form.autorizar" required>
                  <option value="S">✓ AUTORIZAR FECHA</option>
                  <option value="N">✗ BLOQUEAR FECHA</option>
                </select>
              </div>
            </div>
            <div class="row">
              <div class="col-md-6 mb-3">
                <label class="municipal-form-label">Fecha Límite *</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="form.fecha_limite"
                  required
                />
              </div>
              <div class="col-md-6 mb-3">
                <label class="municipal-form-label">Usuario con Permiso *</label>
                <select class="municipal-form-control" v-model.number="form.id_usupermiso" required>
                  <option value="">Seleccione...</option>
                  <option
                    v-for="user in usuarios"
                    :key="user.id_usuario"
                    :value="user.id_usuario"
                  >
                    {{ user.nombre }} ({{ user.usuario }})
                  </option>
                </select>
              </div>
            </div>
            <div class="row">
              <div class="col-md-12 mb-3">
                <label class="municipal-form-label">Comentarios</label>
                <textarea
                  class="municipal-form-control"
                  v-model="form.comentarios"
                  rows="4"
                  @input="toUpperCase"
                  style="text-transform: uppercase;"
                ></textarea>
              </div>
            </div>
            <div class="d-flex justify-content-end gap-2">
              <button class="btn-municipal-success" type="submit" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                <font-awesome-icon icon="save" v-if="!loading" />
                {{ editing ? 'Actualizar' : 'Guardar' }}
              </button>
              <button class="btn-municipal-secondary" type="button" @click="cancelar">
                <font-awesome-icon icon="times" />
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Lista de Autorizaciones -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Fechas Autorizadas
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
                  <th>Permiso</th>
                  <th>Fecha Límite</th>
                  <th>Usuario Permiso</th>
                  <th>Comentarios</th>
                  <th>Actualización</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in fechas" :key="`${item.fecha_ingreso}-${item.oficina}`">
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
                    <button
                      class="btn btn-sm btn-municipal-warning"
                      @click="editarFecha(item)"
                      :disabled="loading"
                    >
                      <font-awesome-icon icon="edit" />
                      Editar
                    </button>
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
  faUserShield, faCalendarCheck, faList, faSave, faTimes,
  faQuestionCircle, faSyncAlt, faEdit
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

library.add(
  faUserShield, faCalendarCheck, faList, faSave, faTimes,
  faQuestionCircle, faSyncAlt, faEdit
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
const usuarios = ref([]);
const fechas = ref([]);
const editing = ref(false);

// Formulario
const form = ref({
  fecha_ingreso: '',
  oficina: 1, // TODO: Obtener de sesión
  autorizar: 'S',
  fecha_limite: '',
  id_usupermiso: '',
  comentarios: ''
});

// Cargar datos iniciales
onMounted(() => {
  cargarUsuarios();
  cargarDatos();
});

// Cargar usuarios con permiso
async function cargarUsuarios() {
  try {
    showLoading('Cargando usuarios', 'Por favor espere');
    const p_oficina = 1; // TODO: Obtener de sesión

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_users_with_permission',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(p_oficina) }
        ]
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      usuarios.value = response.data.eResponse.data.result;
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

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_list_autcargapag',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(p_oficina) }
        ]
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      fechas.value = response.data.eResponse.data.result;
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
          { Nombre: 'p_comentarios', Valor: form.value.comentarios.toUpperCase() },
          { Nombre: 'p_id_usuario', Valor: 1 }, // TODO: Obtener de sesión
          { Nombre: 'p_actualizacion', Valor: ahora }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      showToast(editing.value ? 'Autorización actualizada' : 'Autorización creada', 'success');
      cancelar();
      await cargarDatos();
    }
  } catch (error) {
    console.error('Error al guardar autorización:', error);
    showToast('Error al guardar autorización', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Editar fecha
function editarFecha(item) {
  form.value = {
    fecha_ingreso: item.fecha_ingreso?.split('T')[0] || item.fecha_ingreso,
    oficina: item.oficina,
    autorizar: item.autorizar,
    fecha_limite: item.fecha_limite?.split('T')[0] || item.fecha_limite,
    id_usupermiso: item.id_usupermiso,
    comentarios: item.comentarios || ''
  };
  editing.value = true;

  // Scroll al formulario
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

// Cancelar edición
function cancelar() {
  form.value = {
    fecha_ingreso: '',
    oficina: 1, // TODO: Obtener de sesión
    autorizar: 'S',
    fecha_limite: '',
    id_usupermiso: '',
    comentarios: ''
  };
  editing.value = false;
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
          <li>Complete el formulario para crear una nueva autorización de fecha</li>
          <li>Seleccione si desea AUTORIZAR o BLOQUEAR la fecha</li>
          <li>Indique la fecha límite de validez de la autorización</li>
          <li>Seleccione el usuario que tendrá el permiso</li>
          <li>Agregue comentarios explicativos (se convertirán a mayúsculas)</li>
          <li>Use "Guardar" para crear o "Actualizar" para modificar</li>
          <li>Puede editar autorizaciones existentes haciendo clic en "Editar"</li>
        </ol>
        <p><strong>Nota:</strong> La fecha de ingreso no puede modificarse una vez creada.</p>
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

