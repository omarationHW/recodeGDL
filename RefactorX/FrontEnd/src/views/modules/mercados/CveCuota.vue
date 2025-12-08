<template>
  <div class="container-fluid py-4">
    <div class="municipal-card" style="min-height: 100px;">
      <div class="municipal-card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Catálogo de Claves de Cuota</h5>
        <button class="btn btn-municipal-primary btn-sm" @click="abrirModal(null)">
          <i class="bi bi-plus-circle me-1"></i> Agregar
        </button>
      </div>
      <div class="municipal-card-body">

      </div>


    </div>

    <div class="mt-4" style="margin: 3cap; min-height: 500px; overflow-y: auto;">
      <!-- Loading -->
      <div v-if="loading" class="text-center py-4">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>

      <!-- Tabla -->
      <div v-else class="table-responsive">
        <table class="table table-sm table-striped table-hover municipal-table">
          <thead>
            <tr>
              <th>Clave</th>
              <th>Descripción</th>
              <th width="120">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in cveCuotas" :key="item.clave_cuota">
              <td>{{ item.clave_cuota }}</td>
              <td>{{ item.descripcion }}</td>
              <td>
                <button class="btn btn-sm btn-outline-primary me-1" @click="abrirModal(item)" title="Editar">
                  <i class="bi bi-pencil">Editar</i>
                </button>
                <button class="btn btn-sm btn-outline-danger" @click="eliminar(item)" title="Eliminar">
                  <i class="bi bi-trash">Eliminar</i>
                </button>
              </td>
            </tr>
            <tr v-if="!cveCuotas.length">
              <td colspan="3" class="text-center text-muted py-3">No hay claves de cuota registradas</td>
            </tr>
          </tbody>
        </table>

        <!-- Paginación -->
        <div v-if="cveCuotas.length" class="d-flex justify-content-between align-items-center mt-3">
          <small class="text-muted">Total: {{ cveCuotas.length }} registros</small>
        </div>
      </div>
    </div>


    <!-- Modal Formulario -->
    <div v-if="showModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ isEditing ? 'Editar' : 'Agregar' }} Clave de Cuota</h5>
            <button type="button" class="btn-close" @click="showModal = false"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Clave de Cuota <span class="text-danger">*</span></label>
              <input v-model="form.clave_cuota" type="number" class="form-control" :disabled="isEditing" required />
            </div>
            <div class="mb-3">
              <label class="form-label">Descripción <span class="text-danger">*</span></label>
              <input v-model="form.descripcion" type="text" class="form-control" maxlength="50" required />
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showModal = false">Cancelar</button>
            <button type="button" class="btn btn-municipal-primary" @click="guardar" :disabled="saving">
              <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
              {{ isEditing ? 'Actualizar' : 'Guardar' }}
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showModal" class="modal-backdrop fade show"></div>

    <!-- Modal de Mensajes -->
    <div v-if="showMessageModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header" :class="messageModal.headerClass">
            <h5 class="modal-title">{{ messageModal.title }}</h5>
            <button type="button" class="btn-close" @click="showMessageModal = false"></button>
          </div>
          <div class="modal-body">
            <p class="mb-0">{{ messageModal.message }}</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showMessageModal = false">Cerrar</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showMessageModal" class="modal-backdrop fade show"></div>

    <!-- Modal de Confirmación -->
    <div v-if="showConfirmModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header bg-warning text-dark">
            <h5 class="modal-title">Confirmar</h5>
            <button type="button" class="btn-close" @click="showConfirmModal = false"></button>
          </div>
          <div class="modal-body">
            <p class="mb-0">{{ confirmMessage }}</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showConfirmModal = false">Cancelar</button>
            <button type="button" class="btn btn-warning" @click="ejecutarConfirm">Aceptar</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showConfirmModal" class="modal-backdrop fade show"></div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading();

const loading = ref(false);
const saving = ref(false);
const cveCuotas = ref([]);
const isEditing = ref(false);
const showModal = ref(false);

// Modal de mensajes
const showMessageModal = ref(false);
const messageModal = ref({
  title: '',
  message: '',
  headerClass: ''
});

// Modal de confirmación
const showConfirmModal = ref(false);
const confirmMessage = ref('');
const confirmCallback = ref(null);

const form = ref({
  clave_cuota: '',
  descripcion: ''
});

const mostrarMensaje = (mensaje, tipo = 'info') => {
  const config = {
    success: { title: 'Éxito', headerClass: 'bg-success text-white' },
    error: { title: 'Error', headerClass: 'bg-danger text-white' },
    warning: { title: 'Advertencia', headerClass: 'bg-warning text-dark' },
    info: { title: 'Información', headerClass: 'bg-info text-white' }
  };
  messageModal.value = {
    title: config[tipo].title,
    message: mensaje,
    headerClass: config[tipo].headerClass
  };
  showMessageModal.value = true;
};

const mostrarConfirm = (mensaje, callback) => {
  confirmMessage.value = mensaje;
  confirmCallback.value = callback;
  showConfirmModal.value = true;
};

const ejecutarConfirm = () => {
  showConfirmModal.value = false;
  if (confirmCallback.value) {
    confirmCallback.value();
  }
};

const cargarCveCuotas = async () => {
  showLoading('Cargando Claves de Cuota', 'Preparando catálogo...');
  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cve_cuota_list',
        Base: 'padron_licencias',
        Parametros: []
      }
    });
    if (response.data.eResponse?.success) {
      cveCuotas.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar claves de cuota:', error);
    mostrarMensaje('Error al cargar claves de cuota', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
};

const abrirModal = (item) => {
  if (item) {
    isEditing.value = true;
    form.value = {
      clave_cuota: item.clave_cuota,
      descripcion: item.descripcion
    };
  } else {
    isEditing.value = false;
    form.value = {
      clave_cuota: '',
      descripcion: ''
    };
  }
  showModal.value = true;
};

const guardar = async () => {
  if (!form.value.clave_cuota || !form.value.descripcion) {
    mostrarMensaje('Complete todos los campos requeridos', 'warning');
    return;
  }

  saving.value = true;
  try {
    const operacion = isEditing.value ? 'sp_cve_cuota_update' : 'sp_cve_cuota_create';
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_clave_cuota', Valor: parseInt(form.value.clave_cuota) },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion }
        ]
      }
    });

    if (response.data.eResponse?.success) {
      const result = response.data.eResponse.data.result?.[0];
      if (result?.success !== false) {
        showModal.value = false;
        await cargarCveCuotas();
        mostrarMensaje(isEditing.value ? 'Clave de cuota actualizada correctamente' : 'Clave de cuota creada correctamente', 'success');
      } else {
        mostrarMensaje(result?.message || 'Error al guardar', 'error');
      }
    }
  } catch (error) {
    console.error('Error al guardar:', error);
    mostrarMensaje('Error al guardar clave de cuota', 'error');
  } finally {
    saving.value = false;
  }
};

const eliminar = (item) => {
  mostrarConfirm(`¿Está seguro de eliminar la clave ${item.clave_cuota}?`, async () => {
    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_cve_cuota_delete',
          Base: 'padron_licencias',
          Parametros: [
            { Nombre: 'p_clave_cuota', Valor: item.clave_cuota }
          ]
        }
      });

      if (response.data.eResponse?.success) {
        await cargarCveCuotas();
        mostrarMensaje('Clave de cuota eliminada correctamente', 'success');
      }
    } catch (error) {
      console.error('Error al eliminar:', error);
      mostrarMensaje('Error al eliminar clave de cuota', 'error');
    }
  });
};

onMounted(() => {
  cargarCveCuotas();
});
</script>
