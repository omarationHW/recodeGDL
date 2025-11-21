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
        <button class="btn-municipal-success" @click="showModal('create')">
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
                <tr v-for="row in rows" :key="row.id_mercado"
                    :class="{ 'table-active': selectedRow?.id_mercado === row.id_mercado }"
                    @click="selectedRow = row">
                  <td>{{ row.id_mercado }}</td>
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado_nvo }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td>{{ row.zona || '-' }}</td>
                  <td>
                    <span :class="row.vigencia === 'A' ? 'badge bg-success' : 'badge bg-danger'">
                      {{ row.vigencia === 'A' ? 'Activo' : 'Baja' }}
                    </span>
                  </td>
                  <td>
                    <button class="btn btn-sm btn-warning me-1" @click.stop="showModal('update', row)">
                      <font-awesome-icon icon="edit" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
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
                  <label class="form-label">Oficina *</label>
                  <input type="number" class="form-control" v-model.number="form.oficina"
                         required :disabled="formMode === 'update'" min="1" />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Núm. Mercado *</label>
                  <input type="number" class="form-control" v-model.number="form.num_mercado_nvo"
                         required :disabled="formMode === 'update'" min="1" />
                </div>
              </div>
              <div class="mb-3">
                <label class="form-label">Descripción *</label>
                <input type="text" class="form-control" v-model="form.descripcion"
                       required maxlength="100" />
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Categoría</label>
                  <select class="form-select" v-model.number="form.categoria">
                    <option value="">Seleccione...</option>
                    <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                      {{ cat.categoria }} - {{ cat.descripcion }}
                    </option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Zona</label>
                  <input type="number" class="form-control" v-model.number="form.zona" min="0" />
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeModal">Cancelar</button>
            <button type="button" class="btn btn-success" @click="submitForm" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
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
import { ref, onMounted } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';

const router = useRouter();

// State
const rows = ref([]);
const categorias = ref([]);
const selectedRow = ref(null);
const loading = ref(false);
const showFormModal = ref(false);
const formMode = ref('create');
const form = ref({
  id_mercado: null,
  oficina: '',
  num_mercado_nvo: '',
  descripcion: '',
  categoria: '',
  zona: ''
});

// Toast
const showToast = (type, message) => {
  Swal.fire({
    toast: true,
    position: 'top-end',
    icon: type,
    title: message,
    showConfirmButton: false,
    timer: 3000
  });
};

// Cerrar
const cerrar = () => {
  router.push('/mercados');
};

// Cargar mercados
async function fetchData() {
  loading.value = true;
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
      showToast('error', response.data?.eResponse?.message || 'Error al cargar datos');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('error', 'Error al cargar mercados');
  } finally {
    loading.value = false;
  }
}

// Cargar categorías
async function fetchCategorias() {
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
      categoria: '',
      zona: ''
    };
  } else if (row) {
    form.value = {
      id_mercado: row.id_mercado,
      oficina: row.oficina,
      num_mercado_nvo: row.num_mercado_nvo,
      descripcion: row.descripcion,
      categoria: row.categoria || '',
      zona: row.zona || ''
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
    showToast('warning', 'Complete los campos requeridos');
    return;
  }

  loading.value = true;
  try {
    const sp = formMode.value === 'create' ? 'sp_catalogo_mntto_create' : 'sp_catalogo_mntto_update';
    const params = formMode.value === 'create'
      ? [
          { Nombre: 'p_oficina', Valor: form.value.oficina, tipo: 'integer' },
          { Nombre: 'p_num_mercado_nvo', Valor: form.value.num_mercado_nvo, tipo: 'integer' },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion },
          { Nombre: 'p_categoria', Valor: form.value.categoria || null, tipo: 'integer' },
          { Nombre: 'p_zona', Valor: form.value.zona || null, tipo: 'integer' }
        ]
      : [
          { Nombre: 'p_id_mercado', Valor: form.value.id_mercado, tipo: 'integer' },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion },
          { Nombre: 'p_categoria', Valor: form.value.categoria || null, tipo: 'integer' },
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
      showToast('success', formMode.value === 'create' ? 'Mercado creado' : 'Mercado actualizado');
      closeModal();
      fetchData();
    } else {
      showToast('error', response.data?.eResponse?.message || 'Error al guardar');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('error', 'Error al guardar mercado');
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  fetchData();
  fetchCategorias();
});
</script>
