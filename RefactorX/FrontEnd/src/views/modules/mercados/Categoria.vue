<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="tags" />
      </div>
      <div class="module-view-info">
        <h1>Categorías</h1>
        <p>Mercados - Administración de Categorías</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalCrear" :disabled="loading">
          <font-awesome-icon icon="plus" />
          Agregar
        </button>
        <button class="btn-municipal-primary" @click="fetchData" :disabled="loading">
          <font-awesome-icon :icon="loading ? 'spinner' : 'sync'" :spin="loading" />
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
          <!-- Loading -->
          <div v-if="loading" class="text-center py-4">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
          </div>

          <!-- Tabla -->
          <div v-else-if="rows.length > 0" class="table-responsive">
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
                  <td>
                    <button class="btn btn-sm btn-warning me-1" @click.stop="abrirModalEditar(row)">
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button class="btn btn-sm btn-danger" @click.stop="deleteRow(row)">
                      <font-awesome-icon icon="trash" />
                    </button>
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

    <!-- Modal Crear/Editar -->
    <Modal
      v-if="showFormModal"
      :show="showFormModal"
      :title="formMode === 'create' ? 'Agregar Categoría' : 'Modificar Categoría'"
      :icon="formMode === 'create' ? 'plus' : 'edit'"
      size="md"
      @close="closeModal">
      <template #body>
        <form @submit.prevent="submitForm">
          <div class="mb-3">
            <label class="form-label">Código *</label>
            <input type="number" class="form-control" v-model.number="form.categoria"
                   required :disabled="formMode === 'update'" min="1" />
          </div>
          <div class="mb-3">
            <label class="form-label">Descripción *</label>
            <input type="text" class="form-control" v-model="form.descripcion"
                   required maxlength="30" />
          </div>
        </form>
      </template>

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="closeModal">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button
          type="button"
          class="btn-municipal-success"
          @click="submitForm"
          :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Guardar' }}
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import Modal from '@/components/Modal.vue';

const router = useRouter();

// Composables
const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();

// State
const rows = ref([]);
const selectedRow = ref(null);
const loading = ref(false);
const guardando = ref(false);
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
  loading.value = true;
  showLoading('Cargando categorías...');
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
      showToast('success', `Se cargaron ${rows.value.length} categorías`);
    } else {
      showToast('error', response.data?.eResponse?.message || 'Error al cargar datos');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('error', 'Error al cargar categorías');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Modal
function abrirModalCrear() {
  formMode.value = 'create';
  form.value = {
    categoria: '',
    descripcion: ''
  };
  showFormModal.value = true;
}

function abrirModalEditar(row) {
  formMode.value = 'update';
  form.value = {
    categoria: row.categoria,
    descripcion: row.descripcion
  };
  showFormModal.value = true;
}

function closeModal() {
  showFormModal.value = false;
}

// Guardar
async function submitForm() {
  if (!form.value.categoria || !form.value.descripcion) {
    showToast('warning', 'Complete los campos requeridos');
    return;
  }

  guardando.value = true;
  showLoading(formMode.value === 'create' ? 'Guardando categoría...' : 'Actualizando categoría...');
  try {
    const sp = formMode.value === 'create' ? 'sp_categoria_create' : 'sp_categoria_update';
    const params = [
      { Nombre: 'p_categoria', Valor: form.value.categoria, tipo: 'integer' },
      { Nombre: 'p_descripcion', Valor: form.value.descripcion }
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
        showToast('success', result.message || (formMode.value === 'create' ? 'Categoría creada' : 'Categoría actualizada'));
        closeModal();
        await fetchData();
      } else {
        showToast('error', result?.message || 'Error al guardar');
      }
    } else {
      showToast('error', response.data?.eResponse?.message || 'Error al guardar');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('error', 'Error al guardar categoría');
  } finally {
    guardando.value = false;
    hideLoading();
  }
}

// Eliminar
async function deleteRow(row) {
  const result = await Swal.fire({
    title: '¿Eliminar categoría?',
    text: `Se eliminará la categoría ${row.descripcion}`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#3085d6',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  showLoading('Eliminando categoría...');
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
        showToast('success', 'Categoría eliminada');
        await fetchData();
      } else {
        showToast('error', deleteResult?.message || 'Error al eliminar');
      }
    } else {
      showToast('error', response.data?.eResponse?.message || 'Error al eliminar');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('error', 'Error al eliminar categoría');
  } finally {
    hideLoading();
  }
}

onMounted(() => {
  fetchData();
});
</script>
