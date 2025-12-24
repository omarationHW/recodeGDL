<template>
  <div class="module-view">
    <div class="municipal-card">
      <div class="municipal-card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Catálogo de Recargos</h5>
        <button class="btn btn-municipal-primary btn-sm" @click="abrirModal(null)">
          <font-awesome-icon icon="plus-circle" /> Agregar
        </button>
      </div>
      <div class="municipal-card-body">


      </div>
    </div>


    <!-- Tabla -->
    <div class="row mt-3">
      <div class="table-responsive ml-3 mr-3" style="height: 450px; overflow-y: scroll; margin:3dvb;">
        <div class="table-responsive">
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
                    <font-awesome-icon icon="pencil" />
                  </button>
                  <button class="btn btn-sm btn-outline-danger" @click="confirmarEliminar(recargo)" title="Eliminar">
                    <font-awesome-icon icon="trash" />
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

    <!-- Modal Principal: Formulario -->
    <Modal
      :show="showModal"
      :title="isEditing ? 'Editar Recargo' : 'Agregar Recargo'"
      @close="showModal = false"
      :show-default-footer="true"
      :show-cancel-button="true"
      :show-confirm-button="true"
      :cancel-text="'Cancelar'"
      :confirm-text="isEditing ? 'Actualizar' : 'Guardar'"
      :confirm-button-class="'btn-municipal-primary'"
      :loading="saving"
      @confirm="guardar"
    >
      <div class="mb-3">
        <label class="municipal-form-label">Año <span class="text-danger">*</span></label>
        <input v-model="form.axo" type="number" class="municipal-form-control" :disabled="isEditing" required min="2000"
          max="2100" />
      </div>
      <div class="mb-3">
        <label class="municipal-form-label">Mes <span class="text-danger">*</span></label>
        <select v-model="form.periodo" class="municipal-form-control" :disabled="isEditing" required>
          <option value="">Seleccione</option>
          <option v-for="m in 12" :key="m" :value="m">{{ m }}</option>
        </select>
      </div>
      <div class="mb-3">
        <label class="municipal-form-label">Porcentaje <span class="text-danger">*</span></label>
        <input v-model="form.porcentaje" type="number" class="municipal-form-control" step="0.01" required />
      </div>
    </Modal>

    <!-- Modal de Confirmación -->
    <Modal
      :show="showConfirmModal"
      title="Confirmar Eliminación"
      @close="showConfirmModal = false"
      :show-default-footer="true"
      :show-cancel-button="true"
      :show-confirm-button="true"
      :cancel-text="'Cancelar'"
      :confirm-text="'Eliminar'"
      :confirm-button-class="'btn-danger'"
      @confirm="ejecutarEliminar"
    >
      <p class="mb-0">{{ confirmMessage }}</p>
    </Modal>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'Recargos'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - Recargos'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'Recargos'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - Recargos'" @close="showDocumentacion = false" />
</template>

<script setup>
import Swal from 'sweetalert2'

const confirmarAccion = async (titulo, texto, confirmarTexto = 'Sí, continuar') => {
  const result = await Swal.fire({
    title: titulo,
    text: texto,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#6c757d',
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
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue';
import Modal from '@/components/common/Modal.vue';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { withLoading } = useGlobalLoading();
const { showToast } = useToast();

const saving = ref(false);
const recargos = ref([]);
const isEditing = ref(false);
const showModal = ref(false);

// Modal de confirmación
const showConfirmModal = ref(false);
const confirmMessage = ref('');
const recargoToDelete = ref(null);

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
  await withLoading(async () => {
    try {
      const response = await apiService.execute(
          'sp_recargos_ingresos_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        );
      if (response?.success) {
        recargos.value = response.data.result || [];
      }
    } catch (error) {
      console.error('Error al cargar recargos:', error);
      showToast('Error al cargar recargos', 'error');
    }
  }, 'Cargando recargos...', 'Por favor espere');
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
    showToast('Complete todos los campos requeridos', 'warning');
    return;
  }

  saving.value = true;
  try {
    const operacion = isEditing.value ? 'sp_recargos_update_mercados' : 'sp_recargos_create';
    const response = await apiService.execute(
      operacion,
      'mercados',
      [
        { nombre: 'p_axo', valor: parseInt(form.value.axo), tipo: 'integer' },
        { nombre: 'p_periodo', valor: parseInt(form.value.periodo), tipo: 'integer' },
        { nombre: 'p_porcentaje', valor: parseFloat(form.value.porcentaje), tipo: 'numeric' },
        { nombre: 'p_usuario_id', valor: 1, tipo: 'integer' }
      ],
      '',
      null,
      'publico'
    );

    if (response?.success) {
      const result = response.data.result?.[0];
      if (result?.success !== false) {
        showModal.value = false;
        await cargarRecargos();
        showToast(isEditing.value ? 'Recargo actualizado correctamente' : 'Recargo creado correctamente', 'success');
      } else {
        showToast(result?.message || 'Error al guardar', 'error');
      }
    }
  } catch (error) {
    console.error('Error al guardar:', error);
    showToast('Error al guardar recargo', 'error');
  } finally {
    saving.value = false;
  }
};

const confirmarEliminar = (recargo) => {
  confirmMessage.value = `¿Está seguro de eliminar el recargo ${recargo.axo}-${recargo.periodo}?`;
  recargoToDelete.value = recargo;
  showConfirmModal.value = true;
};

const ejecutarEliminar = async () => {
  showConfirmModal.value = false;

  if (!recargoToDelete.value) return;

  await withLoading(async () => {
    try {
      const response = await apiService.execute(
          'sp_recargos_delete',
          'mercados',
          [
            { nombre: 'p_axo', valor: recargoToDelete.value.axo },
            { nombre: 'p_periodo', valor: recargoToDelete.value.periodo }
          ],
          '',
          null,
          'publico'
        );

      if (response?.success) {
        await cargarRecargos();
        showToast('Recargo eliminado correctamente', 'success');
      }
    } catch (error) {
      console.error('Error al eliminar:', error);
      showToast('Error al eliminar recargo', 'error');
    } finally {
      recargoToDelete.value = null;
    }
  }, 'Eliminando recargo...', 'Por favor espere');
};

onMounted(() => {
  cargarRecargos();
});
</script>
