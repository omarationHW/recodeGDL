<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cogs" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Mercados - Mantenimiento</h1>
        <p>Mercados - Administración y Mantenimiento del Catálogo</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="showModal('create')">
          <font-awesome-icon icon="plus" />
          Agregar
        </button>
        <button class="btn-municipal-primary" @click="fetchData" :disabled="loading">
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
      <!-- Tabla de Mercados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Mercados
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
                  <th>Oficina</th>
                  <th>Núm. Mercado</th>
                  <th>Descripción</th>
                  <th>Zona</th>
                  <th>Categoría</th>
                  <th>Vigencia</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in paginatedRows" :key="`${row.oficina}-${row.num_mercado_nvo}`"
                    :class="{ 'table-active': selectedRow?.oficina === row.oficina && selectedRow?.num_mercado_nvo === row.num_mercado_nvo }"
                    @click="selectedRow = row">
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado_nvo }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td>{{ row.id_zona || '-' }}</td>
                  <td>{{ row.categoria || '-' }}</td>
                  <td>
                    <span :class="row.vigencia === 'A' ? 'badge bg-success' : 'badge bg-danger'">
                      {{ row.vigencia === 'A' ? 'Activo' : 'Baja' }}
                    </span>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click.stop="showModal('update', row)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
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

          <!-- Sin datos -->
          <div v-else class="text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
            <p>No hay mercados registrados</p>
          </div>
        </div>
      </div>

      <!-- Categorías disponibles -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="tags" />
            Categorías Disponibles
            <span v-if="categorias.length > 0" class="badge bg-info ms-2">{{ categorias.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div v-if="categorias.length > 0" class="table-responsive">
            <table class="municipal-table table-sm">
              <thead>
                <tr>
                  <th>Código</th>
                  <th>Descripción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="cat in categorias" :key="cat.categoria">
                  <td>{{ cat.categoria }}</td>
                  <td>{{ cat.descripcion }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-else class="text-center py-3 text-muted">
            <p>No hay categorías registradas</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar usando Modal.vue -->
    <Modal
      :show="showFormModal"
      :title="formMode === 'create' ? 'Agregar Mercado' : 'Modificar Mercado'"
      :icon="formMode === 'create' ? 'plus' : 'edit'"
      size="md"
      @close="closeModal"
    >
        <form @submit.prevent="submitForm">
          <div class="row">
            <div class="col-md-6 mb-3">
              <label class="municipal-form-label">Oficina *</label>
              <input type="number" class="municipal-form-control" v-model.number="form.oficina"
                     required :disabled="formMode === 'update'" min="1" />
            </div>
            <div class="col-md-6 mb-3">
              <label class="municipal-form-label">Núm. Mercado *</label>
              <input type="number" class="municipal-form-control" v-model.number="form.num_mercado_nvo"
                     required :disabled="formMode === 'update'" min="1" />
            </div>
          </div>
          <div class="mb-3">
            <label class="municipal-form-label">Descripción *</label>
            <input type="text" class="municipal-form-control" v-model="form.descripcion"
                   required maxlength="100" />
          </div>
          <div class="row">
            <div class="col-md-6 mb-3">
              <label class="municipal-form-label">Categoría</label>
              <select class="municipal-form-control" v-model.number="form.categoria">
                <option value="">Seleccione...</option>
                <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                  {{ cat.categoria }} - {{ cat.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-6 mb-3">
              <label class="municipal-form-label">ID Zona</label>
              <input type="number" class="municipal-form-control" v-model.number="form.zona" min="0" />
            </div>
          </div>
        </form>

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="closeModal">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button type="button" class="btn-municipal-primary" @click="submitForm" :disabled="loading">
          <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
          <font-awesome-icon icon="save" v-if="!loading" />
          Guardar
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import Modal from '@/components/common/Modal.vue';

const router = useRouter();
const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();

// State
const rows = ref([]);
const categorias = ref([]);
const selectedRow = ref(null);
const loading = ref(false);
const showFormModal = ref(false);
const formMode = ref('create');
const form = ref({
  oficina: null,
  num_mercado_nvo: null,
  descripcion: '',
  categoria: null,
  id_zona: null
});

// Paginación
const currentPage = ref(1);
const itemsPerPage = ref(10);

// Computed de paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage.value));

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

// Métodos de paginación
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return;
  currentPage.value = page;
};

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size);
  currentPage.value = 1;
};

// Cerrar
const cerrar = () => {
  router.push('/mercados');
};

// Cargar mercados
async function fetchData() {
  loading.value = true;
  showLoading();
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_catalogo_mntto_list',
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
    showToast('Error al cargar mercados', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Cargar categorías
async function fetchCategorias() {
  showLoading();
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_categorias_list',
        Base: 'mercados',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      categorias.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error cargando categorías:', error);
  } finally {
    hideLoading();
  }
}

// Modal
function showModal(mode, row = null) {
  formMode.value = mode;
  if (mode === 'create') {
    form.value = {
      oficina: null,
      num_mercado_nvo: null,
      descripcion: '',
      categoria: null,
      id_zona: null
    };
  } else if (row) {
    form.value = {
      oficina: row.oficina,
      num_mercado_nvo: row.num_mercado_nvo,
      descripcion: row.descripcion,
      categoria: row.categoria || null,
      id_zona: row.id_zona || null
    };
  }
  showFormModal.value = true;
}

function closeModal() {
  showFormModal.value = false;
}

// Guardar
async function submitForm() {
  if (!form.value.oficina || !form.value.num_mercado_nvo || !form.value.descripcion?.trim()) {
    showToast('Complete los campos requeridos', 'warning');
    return;
  }

  // Validar que sean números válidos
  if (isNaN(form.value.oficina) || isNaN(form.value.num_mercado_nvo)) {
    showToast('Oficina y Número de Mercado deben ser valores numéricos válidos', 'warning');
    return;
  }

  loading.value = true;
  showLoading();
  try {
    const sp = formMode.value === 'create' ? 'sp_catalogo_mntto_create' : 'sp_catalogo_mntto_update';

    console.log('Saving market with data:', form.value);
    const params = formMode.value === 'create'
      ? [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina), tipo: 'smallint' },
          { Nombre: 'p_num_mercado_nvo', Valor: parseInt(form.value.num_mercado_nvo), tipo: 'smallint' },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion.trim() },
          { Nombre: 'p_categoria', Valor: form.value.categoria ? parseInt(form.value.categoria) : null, tipo: 'smallint' },
          { Nombre: 'p_zona', Valor: form.value.zona ? parseInt(form.value.zona) : null, tipo: 'smallint' }
        ]
      : [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina), tipo: 'smallint' },
          { Nombre: 'p_num_mercado_nvo', Valor: parseInt(form.value.num_mercado_nvo), tipo: 'smallint' },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion.trim() },
          { Nombre: 'p_categoria', Valor: form.value.categoria ? parseInt(form.value.categoria) : null, tipo: 'smallint' },
          { Nombre: 'p_zona', Valor: form.value.zona ? parseInt(form.value.zona) : null, tipo: 'smallint' }
        ];

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: sp,
        Base: 'mercados',
        Parametros: params
      }
    });

    if (response.data?.eResponse?.success) {
      showToast(formMode.value === 'create' ? 'Mercado creado' : 'Mercado actualizado', 'success');
      closeModal();
      fetchData();
    } else {
      showToast(response.data?.eResponse?.message || 'Error al guardar', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al guardar mercado', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

onMounted(() => {
  fetchData();
  fetchCategorias();
});
</script>
