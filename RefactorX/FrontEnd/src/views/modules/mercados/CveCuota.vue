<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-bill" />
      </div>
      <div class="module-view-info">
        <h1>Clave de Cuota</h1>
        <p>Inicio > Mercados > Clave de Cuota</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>Clave de Cuota</h5>
        </div>
        <div class="municipal-card-body">
          <div class="mb-3 d-flex gap-2">
            <button class="btn-municipal-primary" @click="abrirModal(null)" :disabled="loading">
              <font-awesome-icon icon="plus-circle" class="me-1" /> Agregar
            </button>
            <button class="btn-municipal-info" @click="cargarCveCuotas" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              <font-awesome-icon icon="sync" v-if="!loading" />
              Refrescar
            </button>
          </div>

          <div v-if="loading" class="text-center py-4">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
          </div>

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
                <tr v-for="item in paginatedCveCuotas" :key="item.clave_cuota">
                  <td>{{ item.clave_cuota }}</td>
                  <td>{{ item.descripcion }}</td>        
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click.stop="abrirModal(item)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-municipal-danger btn-sm" @click.stop="eliminar(item)" title="Eliminar">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="!cveCuotas.length">
                  <td colspan="3" class="text-center text-muted py-3">No hay claves de cuota registradas</td>
                </tr>
              </tbody>
            </table>

            <!-- Controles de Paginación -->
            <div v-if="cveCuotas.length > 0" class="pagination-controls">
              <div class="pagination-info">
                <span class="text-muted">
                  Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                  a {{ Math.min(currentPage * itemsPerPage, cveCuotas.length) }}
                  de {{ cveCuotas.length }} registros
                </span>
              </div>

              <div class="pagination-size">
                <label class="form-label me-2 mb-0">Registros por página:</label>
                <select class="form-select form-select-sm" :value="itemsPerPage"
                  @change="changePageSize($event.target.value)" style="width: auto; display: inline-block;">
                  <option value="10">10</option>
                  <option value="25">25</option>
                  <option value="50">50</option>
                  <option value="100">100</option>
                </select>
              </div>

              <div class="pagination-buttons">
                <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1"
                  title="Primera página">
                  <font-awesome-icon icon="angle-double-left" />
                </button>

                <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)"
                  :disabled="currentPage === 1" title="Página anterior">
                  <font-awesome-icon icon="angle-left" />
                </button>

                <button v-for="page in visiblePages" :key="page" class="btn-sm"
                  :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'" @click="goToPage(page)">
                  {{ page }}
                </button>

                <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)"
                  :disabled="currentPage === totalPages" title="Página siguiente">
                  <font-awesome-icon icon="angle-right" />
                </button>

                <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)"
                  :disabled="currentPage === totalPages" title="Última página">
                  <font-awesome-icon icon="angle-double-right" />
                </button>
              </div>
            </div>
          </div>
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
              <label class="municipal-form-label">Clave de Cuota <span class="text-danger">*</span></label>
              <input v-model="form.clave_cuota" type="number" class="municipal-form-control" :disabled="isEditing"
                required />
            </div>
            <div class="mb-3">
              <label class="municipal-form-label">Descripción <span class="text-danger">*</span></label>
              <input v-model="form.descripcion" type="text" class="municipal-form-control" maxlength="50" required />
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
import Swal from 'sweetalert2';
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading();

const loading = ref(false);
const saving = ref(false);
const cveCuotas = ref([]);
const isEditing = ref(false);
const showModal = ref(false);

// Paginación
const currentPage = ref(1);
const itemsPerPage = ref(10);

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

// Computed de paginación
const totalPages = computed(() => Math.ceil(cveCuotas.value.length / itemsPerPage.value));

const paginatedCveCuotas = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value;
  const end = start + itemsPerPage.value;
  return cveCuotas.value.slice(start, end);
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


// Ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Clave de Cuota',
    html: `
      <div style="text-align: left;">
        <h6>Funcionalidad del mÃ³dulo:</h6>
        <p>Este mÃ³dulo permite administrar las claves de cuotas aplicables.</p>
        <h6>Instrucciones:</h6>
        <ol>
          <li>Las claves de cuota definen los tipos de cobro
          <li>Puede agregar, modificar o dar de baja claves
          <li>Verifique que la clave no estÃ© en uso antes de eliminarla</li>
        </ol>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}

onMounted(() => {
  cargarCveCuotas();
});
</script>

<style scoped>
.gap-2 {
  gap: 0.5rem;
}

.button-group {
  display: inline-flex;
  gap: 0.25rem;
}

.button-group-sm {
  gap: 0.125rem;
}

.pagination-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1rem;
  padding: 1rem 0;
  gap: 1rem;
  flex-wrap: wrap;
}

.pagination-info {
  display: flex;
  align-items: center;
}

.pagination-size {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.pagination-buttons {
  display: flex;
  gap: 0.25rem;
}

.pagination-buttons .btn {
  min-width: 2rem;
}
</style>
