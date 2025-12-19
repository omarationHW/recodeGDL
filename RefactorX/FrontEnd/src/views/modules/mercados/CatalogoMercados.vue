<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Mercados</h1>
        <p>Mercados - Administración del Catálogo de Mercados</p>
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
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
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
                  <th>ID</th>
                  <th>Oficina</th>
                  <th>Núm. Mercado</th>
                  <th>Descripción</th>
                  <th>Zona</th>
                  <th>Vigencia</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in paginatedRows" :key="row.id_mercado"
                    :class="{ 'table-active': selectedRow?.id_mercado === row.id_mercado }"
                    @click="selectedRow = row">
                  <td>{{ row.id_mercado }}</td>
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado_nvo }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td>{{ row.id_zona || '-' }}</td>
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

          <!-- Sin datos -->
          <div v-else class="text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
            <p>No hay mercados registrados</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <div v-if="showFormModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon :icon="formMode === 'create' ? 'plus' : 'edit'" class="me-2" />
              {{ formMode === 'create' ? 'Agregar Mercado' : 'Modificar Mercado' }}
            </h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
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
                  <label class="municipal-form-label">Domicilio</label>
                  <input type="text" class="municipal-form-control" v-model="form.domicilio" maxlength="200" />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Zona</label>
                  <input type="number" class="municipal-form-control" v-model.number="form.zona" min="0" />
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="closeModal">
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
            <button type="button" class="btn-municipal-primary" @click="submitForm" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              <font-awesome-icon icon="save" v-if="!loading" />
              Guardar
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showFormModal" class="modal-backdrop fade show"></div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';

const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();

const router = useRouter();

// State
const rows = ref([]);
const selectedRow = ref(null);
const loading = ref(false);
const showFormModal = ref(false);
const formMode = ref('create');

// Paginación
const currentPage = ref(1);
const itemsPerPage = ref(10);

const form = ref({
  id_mercado: null,
  oficina: '',
  num_mercado_nvo: '',
  descripcion: '',
  domicilio: '',
  zona: ''
});

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(rows.value.length / itemsPerPage.value);
});

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
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
  }
};

const changePageSize = (newSize) => {
  itemsPerPage.value = parseInt(newSize);
  currentPage.value = 1;
};

// Cargar datos
async function fetchData() {
  showLoading('Cargando Catálogo de Mercados', 'Preparando listado de mercados...');
  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_catalogo_mercados_list',
        Base: 'mercados',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      rows.value = response.data.eResponse.data.result || [];
      currentPage.value = 1; // Resetear a la primera página
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

// Modal
function showModal(mode, row = null) {
  formMode.value = mode;
  if (mode === 'create') {
    form.value = {
      id_mercado: null,
      oficina: '',
      num_mercado_nvo: '',
      descripcion: '',
      domicilio: '',
      zona: ''
    };
  } else if (row) {
    form.value = {
      id_mercado: row.id_mercado,
      oficina: row.oficina,
      num_mercado_nvo: row.num_mercado_nvo,
      descripcion: row.descripcion,
      domicilio: row.domicilio || '',
      zona: row.id_zona || ''
    };
  }
  showFormModal.value = true;
}

function closeModal() {
  showFormModal.value = false;
}

// Guardar
async function submitForm() {
  if (!form.value.oficina || !form.value.num_mercado_nvo || !form.value.descripcion) {
    showToast('Complete los campos requeridos', 'warning');
    return;
  }

  loading.value = true;
  try {
    const sp = formMode.value === 'create' ? 'sp_catalogo_mercados_create' : 'sp_catalogo_mercados_update';
    const params = formMode.value === 'create'
      ? [
          { Nombre: 'p_oficina', Valor: form.value.oficina, tipo: 'integer' },
          { Nombre: 'p_num_mercado_nvo', Valor: form.value.num_mercado_nvo, tipo: 'integer' },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion },
          { Nombre: 'p_domicilio', Valor: form.value.domicilio || null },
          { Nombre: 'p_zona', Valor: form.value.zona || null, tipo: 'integer' }
        ]
      : [
          { Nombre: 'p_id_mercado', Valor: form.value.id_mercado, tipo: 'integer' },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion },
          { Nombre: 'p_domicilio', Valor: form.value.domicilio || null },
          { Nombre: 'p_zona', Valor: form.value.zona || null, tipo: 'integer' }
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
  }
}

// Eliminar
async function deleteRow(row) {
  const result = await Swal.fire({
    title: '¿Eliminar mercado?',
    text: `Se eliminará el mercado ${row.descripcion}`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#3085d6',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_catalogo_mercados_delete',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_mercado', Valor: row.id_mercado, tipo: 'integer' }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      showToast('Mercado eliminado', 'success');
      fetchData();
    } else {
      showToast(response.data?.eResponse?.message || 'Error al eliminar', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al eliminar mercado', 'error');
  } finally {
    loading.value = false;
  }
}

// Ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Catálogo de Mercados',
    html: `
      <div style="text-align: left;">
        <h6>Funcionalidad del módulo:</h6>
        <p>Este módulo permite administrar el catálogo de mercados del municipio.</p>
        <h6>Instrucciones:</h6>
        <ol>
          <li>Haga clic en "Agregar" para registrar un nuevo mercado</li>
          <li>Los campos de Oficina y Número de Mercado no pueden modificarse después de crear el registro</li>
          <li>Puede editar o eliminar mercados usando los botones de la tabla</li>
          <li>Use "Refrescar" para actualizar el listado</li>
        </ol>
        <p><strong>Nota:</strong> La eliminación de un mercado puede afectar otros módulos relacionados.</p>
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
