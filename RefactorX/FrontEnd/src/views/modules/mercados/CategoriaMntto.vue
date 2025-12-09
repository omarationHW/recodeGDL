<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cogs" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento de Categorías</h1>
        <p>Mercados - Administración y Mantenimiento de Categorías</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="showModal('create')">
          <font-awesome-icon icon="plus" />
          Agregar
        </button>
        <button class="btn-municipal-primary" @click="fetchData">
          <font-awesome-icon icon="sync" />
          Refrescar
        </button>
        <button class="btn-municipal-danger" @click="cerrar">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Tabla de Categorías -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Categorías
            <span v-if="rows.length > 0" class="badge bg-primary ms-2">{{ rows.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Tabla -->
          <div v-if="rows.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Código</th>
                  <th>Descripción</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in rows" :key="row.categoria"
                    :class="{ 'table-active': selectedRow?.categoria === row.categoria }"
                    @click="selectedRow = row">
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click.stop="showModal('update', row)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-municipal-danger btn-sm" @click.stop="deleteRow(row)" title="Eliminar">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Sin datos -->
          <div v-else class="text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
            <p>No hay categorías registradas</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar con Modal.vue -->
    <Modal
      :show="showFormModal"
      :title="formMode === 'create' ? 'Agregar Categoría' : 'Modificar Categoría'"
      :icon="formMode === 'create' ? 'plus' : 'edit'"
      size="sm"
      @close="closeModal"
    >
        <form @submit.prevent="submitForm">
          <div class="mb-3">
            <label class="municipal-form-label">Código *</label>
            <input type="number" class="municipal-form-control" v-model.number="form.categoria"
                   required :disabled="formMode === 'update'" min="1" max="12" />
          </div>
          <div class="mb-3">
            <label class="municipal-form-label">Descripción *</label>
            <input type="text" class="municipal-form-control text-uppercase" v-model="form.descripcion"
                   required maxlength="30" />
          </div>
        </form>

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="closeModal">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button type="button" class="btn-municipal-success" @click="submitForm">
          <font-awesome-icon icon="save" />
          Guardar
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';
import { useToast } from '@/composables/useToast';
import Modal from '@/components/common/Modal.vue';

const router = useRouter();
const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();

// State
const rows = ref([]);
const selectedRow = ref(null);
const showFormModal = ref(false);
const formMode = ref('create');
const form = ref({
  categoria: '',
  descripcion: ''
});

// Cerrar
const cerrar = () => {
  router.push('/mercados');
};

// Cargar datos
async function fetchData() {
  showLoading('Cargando categorías...', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_categoria_list',
        Base: 'mercados',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      rows.value = response.data.eResponse.data.result || [];
    } else {
      showToast(response.data?.eResponse?.message || 'Error al cargar datos', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al cargar categorías', 'error');
  } finally {
    hideLoading();
  }
}

// Modal
function showModal(mode, row = null) {
  formMode.value = mode;
  if (mode === 'create') {
    form.value = {
      categoria: '',
      descripcion: ''
    };
  } else if (row) {
    form.value = {
      categoria: row.categoria,
      descripcion: row.descripcion
    };
  }
  showFormModal.value = true;
}

function closeModal() {
  showFormModal.value = false;
}

// Guardar
async function submitForm() {
  if (!form.value.categoria || !form.value.descripcion) {
    showToast('Complete los campos requeridos', 'warning');
    return;
  }

  showLoading('Guardando categoría...', 'Por favor espere');
  try {
    const sp = formMode.value === 'create' ? 'sp_categoria_create' : 'sp_categoria_update';
    const params = [
      { Nombre: 'p_categoria', Valor: form.value.categoria, tipo: 'integer' },
      { Nombre: 'p_descripcion', Valor: form.value.descripcion.toUpperCase() }
    ];

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: sp,
        Base: 'mercados',
        Parametros: params
      }
    });

    if (response.data?.eResponse?.success) {
      const result = response.data.eResponse.data.result?.[0];
      if (result?.success) {
        showToast(result.message || (formMode.value === 'create' ? 'Categoría creada' : 'Categoría actualizada'), 'success');
        closeModal();
        fetchData();
      } else {
        showToast(result?.message || 'Error al guardar', 'error');
      }
    } else {
      showToast(response.data?.eResponse?.message || 'Error al guardar', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al guardar categoría', 'error');
  } finally {
    hideLoading();
  }
}

// Eliminar
async function deleteRow(row) {
  const result = await Swal.fire({
    title: '¿Eliminar categoría?',
    text: `Se eliminará la categoría ${row.categoria} - ${row.descripcion}`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#3085d6',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  showLoading('Eliminando categoría...', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_categoria_delete',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_categoria', Valor: row.categoria, tipo: 'integer' }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      const deleteResult = response.data.eResponse.data.result?.[0];
      if (deleteResult?.success) {
        showToast('Categoría eliminada', 'success');
        fetchData();
      } else {
        showToast(deleteResult?.message || 'Error al eliminar', 'error');
      }
    } else {
      showToast(response.data?.eResponse?.message || 'Error al eliminar', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al eliminar categoría', 'error');
  } finally {
    hideLoading();
  }
}

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.module-view-header .btn-municipal-primary {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: white !important;
}
</style>
