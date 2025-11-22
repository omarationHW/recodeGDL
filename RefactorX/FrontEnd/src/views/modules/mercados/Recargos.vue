<template>
  <div class="container-fluid py-4">
    <div class="municipal-card">
      <div class="municipal-card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Catálogo de Recargos</h5>
        <button class="btn btn-municipal-primary btn-sm" @click="abrirModal(null)">
          <i class="bi bi-plus-circle me-1"></i> Agregar
        </button>
      </div>
      <div class="municipal-card-body">


      </div>
    </div>


    <!-- Tabla -->
    <div class="row mt-3">
      <div class="table-responsive ml-3 mr-3" style="height: 450px; overflow-y: scroll; margin:3dvb;">
        <!-- Loading -->
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
        <div v-else class="table-responsive">
          <table class="table table-sm table-striped table-hover municipal-table">
            <thead>
              <tr>
                <th>Año</th>
                <th>Mes</th>
                <th>Porcentaje</th>
                <th>Fecha Alta</th>
                <th>Usuario</th>
                <th width="120">Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="recargo in recargos" :key="`${recargo.axo}-${recargo.periodo}`">
                <td>{{ recargo.axo }}</td>
                <td>{{ recargo.periodo }}</td>
                <td>{{ recargo.porcentaje }}%</td>
                <td>{{ formatDate(recargo.fecha_alta) }}</td>
                <td>{{ recargo.usuario }}</td>
                <td>
                  <button class="btn btn-sm btn-outline-primary me-1" @click="abrirModal(recargo)" title="Editar">
                    <i class="bi bi-pencil">Editar</i>
                  </button>
                  <button class="btn btn-sm btn-outline-danger" @click="eliminar(recargo)" title="Eliminar">
                    <i class="bi bi-trash">Eliminar</i>
                  </button>
                </td>
              </tr>
              <tr v-if="!recargos.length">
                <td colspan="6" class="text-center text-muted py-3">No hay recargos registrados</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Paginación simple -->
    <div v-if="recargos.length" class="d-flex justify-content-between align-items-center mt-3">
      <small class="text-muted">Total: {{ recargos.length }} registros</small>
    </div>

    <!-- Modal -->
    <div v-if="showModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ isEditing ? 'Editar' : 'Agregar' }} Recargo</h5>
            <button type="button" class="btn-close" @click="showModal = false"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Año <span class="text-danger">*</span></label>
              <input v-model="form.axo" type="number" class="form-control" :disabled="isEditing" required min="2000"
                max="2100" />
            </div>
            <div class="mb-3">
              <label class="form-label">Mes <span class="text-danger">*</span></label>
              <select v-model="form.periodo" class="form-select" :disabled="isEditing" required>
                <option value="">Seleccione</option>
                <option v-for="m in 12" :key="m" :value="m">{{ m }}</option>
              </select>
            </div>
            <div class="mb-3">
              <label class="form-label">Porcentaje <span class="text-danger">*</span></label>
              <input v-model="form.porcentaje" type="number" class="form-control" step="0.01" required />
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

const loading = ref(false);
const saving = ref(false);
const recargos = ref([]);
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

const form = ref({
  axo: '',
  periodo: '',
  porcentaje: ''
});

const formatDate = (value) => {
  if (!value) return '';
  return new Date(value).toLocaleDateString('es-MX');
};

const cargarRecargos = async () => {
  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_recargos_list',
        Base: 'padron_licencias',
        Parametros: []
      }
    });
    if (response.data.eResponse?.success) {
      recargos.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar recargos:', error);
    mostrarMensaje('Error al cargar recargos', 'error');
  } finally {
    loading.value = false;
  }
};

const abrirModal = (recargo) => {
  if (recargo) {
    isEditing.value = true;
    form.value = {
      axo: recargo.axo,
      periodo: recargo.periodo,
      porcentaje: recargo.porcentaje
    };
  } else {
    isEditing.value = false;
    form.value = {
      axo: new Date().getFullYear(),
      periodo: '',
      porcentaje: ''
    };
  }
  showModal.value = true;
};

const guardar = async () => {
  if (!form.value.axo || !form.value.periodo || !form.value.porcentaje) {
    mostrarMensaje('Complete todos los campos requeridos', 'warning');
    return;
  }

  saving.value = true;
  try {
    const operacion = isEditing.value ? 'sp_recargos_update' : 'sp_recargos_create';
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(form.value.periodo) },
          { Nombre: 'p_porcentaje', Valor: parseFloat(form.value.porcentaje) },
          { Nombre: 'p_usuario_id', Valor: 1 }
        ]
      }
    });

    if (response.data.eResponse?.success) {
      const result = response.data.eResponse.data.result?.[0];
      if (result?.success !== false) {
        showModal.value = false;
        await cargarRecargos();
        mostrarMensaje(isEditing.value ? 'Recargo actualizado correctamente' : 'Recargo creado correctamente', 'success');
      } else {
        mostrarMensaje(result?.message || 'Error al guardar', 'error');
      }
    }
  } catch (error) {
    console.error('Error al guardar:', error);
    mostrarMensaje('Error al guardar recargo', 'error');
  } finally {
    saving.value = false;
  }
};

const eliminar = (recargo) => {
  mostrarConfirm(`¿Está seguro de eliminar el recargo ${recargo.axo}-${recargo.periodo}?`, async () => {
    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_recargos_delete',
          Base: 'padron_licencias',
          Parametros: [
            { Nombre: 'p_axo', Valor: recargo.axo },
            { Nombre: 'p_periodo', Valor: recargo.periodo }
          ]
        }
      });

      if (response.data.eResponse?.success) {
        await cargarRecargos();
        mostrarMensaje('Recargo eliminado correctamente', 'success');
      }
    } catch (error) {
      console.error('Error al eliminar:', error);
      mostrarMensaje('Error al eliminar recargo', 'error');
    }
  });
};

onMounted(() => {
  cargarRecargos();
});
</script>
