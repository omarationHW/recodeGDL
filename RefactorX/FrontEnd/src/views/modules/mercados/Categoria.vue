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
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
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
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Categorías
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="rows.length > 0">
              {{ rows.length }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <!-- Loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando categorías...</p>
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Código</th>
                  <th>Descripción</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="rows.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay categorías registradas</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, idx) in paginatedData" :key="row.categoria" class="row-hover"
                  :class="{ 'table-active': selectedRow?.categoria === row.categoria }" @click="selectedRow = row">
                  <td class="text-center">{{ (currentPage - 1) * itemsPerPage + idx + 1 }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-center">
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

          <!-- Controles de paginación -->
          <div v-if="rows.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, rows.length) }}
                de {{ rows.length }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPage"
                @change="changePageSize($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(1)"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
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
      
  <DocumentationModal :show="showAyuda" :component-name="'Categoria'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - Categoria'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'Categoria'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - Categoria'" @close="showDocumentacion = false" />
</template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import Modal from '@/components/common/Modal.vue';
import { useApi } from '@/composables/useApi'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


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
});

// Paginación
const currentPage = ref(1);
const itemsPerPage = ref(10);

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(rows.value.length / itemsPerPage.value)
});

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return rows.value.slice(start, end)
});

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
});

// Métodos de paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
};

const changePageSize = (newSize) => {
  itemsPerPage.value = parseInt(newSize)
  currentPage.value = 1
};

const resetPagination = () => {
  currentPage.value = 1
  itemsPerPage.value = 10
};// Cargar datos
async function fetchData() {
  loading.value = true;
  showLoading('Cargando categorías...');
  try {
    const response = await execute('sp_categoria_list', 'mercados', [], '', null, 'publico');

    rows.value = response?.result || [];
    resetPagination();
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
      { nombre: 'p_categoria', valor: form.value.categoria, tipo: 'integer' },
      { nombre: 'p_descripcion', valor: form.value.descripcion }
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
      { nombre: 'p_categoria', valor: row.categoria, tipo: 'integer' }
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


// Ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - CategorÃ­as',
    html: `
      <div style="text-align: left;">
        <h6>Funcionalidad del mÃ³dulo:</h6>
        <p>Este mÃ³dulo permite gestionar las categorÃ­as de los locales en mercados.</p>
        <h6>Instrucciones:</h6>
        <ol>
          <li>Las categorÃ­as determinan las cuotas aplicables a cada local
          <li>Puede agregar, modificar o eliminar categorÃ­as
          <li>AsegÃºrese de que las categorÃ­as estÃ©n correctamente configuradas antes de asignarlas a locales</li>
        </ol>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}

onMounted(() => {
  fetchData();
});
</script>
