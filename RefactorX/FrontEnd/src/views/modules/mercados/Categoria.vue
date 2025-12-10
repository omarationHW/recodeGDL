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
        <button class="btn-municipal-primary" @click="abrirModalCrear" :disabled="loading">
          <font-awesome-icon icon="plus" />
          Agregar
        </button>
        <button class="btn-municipal-primary" @click="fetchData" :disabled="loading">
          <font-awesome-icon :icon="loading ? 'spinner' : 'sync'" :spin="loading" />
          Refrescar
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
                  :class="{ 'table-active': selectedRow?.categoria === row.categoria }" @click="selectedRow = row">
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click.stop="abrirModalEditar(row)" title="Editar">
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

    <!-- Modal Crear/Editar -->
    <Modal v-if="showFormModal" :show="showFormModal"
      :title="formMode === 'create' ? 'Agregar Categoría' : 'Modificar Categoría'"
      :icon="formMode === 'create' ? 'plus' : 'edit'" size="md" @close="closeModal">
      <form @submit.prevent="submitForm">
        <div class="mb-3">
          <label class="municipal-form-label">Código *</label>
          <input type="number" class="municipal-form-control" v-model.number="form.categoria" required
            :disabled="formMode === 'update'" min="1" />
        </div>
        <div class="mb-3">
          <label class="municipal-form-label">Descripción *</label>
          <input type="text" class="municipal-form-control" v-model="form.descripcion" required maxlength="30" />
        </div>
      </form>

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="closeModal">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button type="button" class="btn-municipal-primary" @click="submitForm" :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Guardar' }}
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import Modal from '@/components/common/Modal.vue';
import { useApi } from '@/composables/useApi'

const router = useRouter();

// Composables
const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();
const { execute } = useApi();

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
});// Cargar datos
async function fetchData() {
  loading.value = true;
  showLoading('Cargando categorías...');
  try {
    const response = await execute('sp_categoria_list', 'mercados', [], '', null, 'publico');

    rows.value = response?.result || [];
    showToast(`Se cargaron ${rows.value.length} categorías`, 'success');
  } catch (error) {
    console.error('Error:', error);
    showToast(error.message || 'Error al cargar categorías', 'error');
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
    showToast('Complete los campos requeridos', 'warning');
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

    const response = await execute(sp, 'mercados', params, '', null, 'publico');

    if (response?.result?.[0]?.success) {
      showToast(response.result[0].message || (formMode.value === 'create' ? 'Categoría creada' : 'Categoría actualizada'), 'success');
      closeModal();
      await fetchData();
    } else {
      showToast(response?.result?.[0]?.message || 'Error al guardar', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast(error.message || 'Error al guardar categoría', 'error');
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
    const params = [
      { Nombre: 'p_categoria', Valor: row.categoria, tipo: 'integer' }
    ];

    const response = await execute('sp_categoria_delete', 'mercados', params, '', null, 'publico');

    if (response?.result?.[0]?.success) {
      showToast('Categoría eliminada', 'success');
      await fetchData();
    } else {
      showToast(response?.result?.[0]?.message || 'Error al eliminar', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast(error.message || 'Error al eliminar categoría', 'error');
  } finally {
    hideLoading();
  }
}

onMounted(() => {
  fetchData();
});
</script>
