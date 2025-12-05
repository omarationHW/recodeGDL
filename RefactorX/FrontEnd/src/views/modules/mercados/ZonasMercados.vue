<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Zonas Geográficas</h1>
        <p>Inicio > Mercados > Zonas Geográficas</p>
      </div>
      <div class="button-group ms-auto">
        
        <button class="btn-municipal-success" @click="cargarZonas" :disabled="loading">
          <font-awesome-icon icon="sync-alt" /> Actualizar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border municipal-text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-2">Cargando zonas...</p>
      </div>

      <div v-if="!loading && zonas.length === 0" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No hay zonas registradas.
      </div>

      <div v-if="!loading && zonas.length > 0" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Zonas Registradas</h5>
          <div class="header-right">
            <span class="badge-purple">{{ zonas.length }} zonas</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Zona</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="zona in paginatedZonas" :key="zona.id_zona" class="row-hover">
                  <td>{{ zona.zona }}</td>
                  <td class="text-center">
            
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="pagination-container">
            <div class="pagination-info">
              <label>Mostrar:</label>
              <select v-model.number="pageSize" class="municipal-form-control pagination-select">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
              </select>
              <span>registros por página</span>
            </div>
            <div class="pagination-controls">
              <button class="btn-municipal-secondary btn-sm" @click="currentPage--" :disabled="currentPage === 1">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar Zona -->
    <div v-if="showModal" class="modal-overlay" @click.self="cerrarModal">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header municipal-bg-primary">
            <h5 class="modal-title">
              <font-awesome-icon :icon="modoEdicion ? 'edit' : 'plus'" />
              {{ modoEdicion ? 'Editar Zona' : 'Nueva Zona' }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarZona">
              <div class="form-group">
                <label class="municipal-form-label">ID Zona <span class="required">*</span></label>
                <input
                  type="number"
                  v-model.number="form.id_zona"
                  class="municipal-form-control"
                  :disabled="modoEdicion"
                  required
                  min="1"
                />
                <small class="form-text text-muted" v-if="!modoEdicion">El ID debe ser único</small>
              </div>
              <div class="form-group mt-3">
                <label class="municipal-form-label">Nombre de la Zona <span class="required">*</span></label>
                <input
                  type="text"
                  v-model="form.zona"
                  class="municipal-form-control"
                  required
                  maxlength="30"
                />
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button type="button" class="btn-municipal-primary" @click="guardarZona" :disabled="guardando">
              <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
              {{ guardando ? 'Guardando...' : 'Guardar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Confirmar Eliminación -->
    <div v-if="showDeleteModal" class="modal-overlay" @click.self="cerrarModalEliminar">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header municipal-bg-danger">
            <h5 class="modal-title">
              <font-awesome-icon icon="exclamation-triangle" />
              Confirmar Eliminación
            </h5>
            <button type="button" class="btn-close" @click="cerrarModalEliminar"></button>
          </div>
          <div class="modal-body">
            <p>¿Está seguro que desea eliminar la zona <strong>{{ zonaEliminar?.zona }}</strong>?</p>
            <p class="text-danger">Esta acción no se puede deshacer.</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarModalEliminar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button type="button" class="btn-municipal-danger" @click="eliminarZona" :disabled="eliminando">
              <font-awesome-icon :icon="eliminando ? 'spinner' : 'trash'" :spin="eliminando" />
              {{ eliminando ? 'Eliminando...' : 'Eliminar' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';

const zonas = ref([]);
const loading = ref(false);
const guardando = ref(false);
const eliminando = ref(false);
const showModal = ref(false);
const showDeleteModal = ref(false);
const modoEdicion = ref(false);
const zonaEliminar = ref(null);
const currentPage = ref(1);
const pageSize = ref(25);

const form = ref({
  id_zona: null,
  zona: ''
});

const totalPages = computed(() => Math.ceil(zonas.value.length / pageSize.value) || 1);
const paginatedZonas = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return zonas.value.slice(start, start + pageSize.value);
});

onMounted(() => {
  cargarZonas();
});

const cargarZonas = async () => {
  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_zonas_list',
        Base: 'padron_licencias',
        Parametros: []
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      zonas.value = response.data.eResponse.data.result;
    } else {
      zonas.value = [];
    }
  } catch (error) {
    console.error('Error:', error);
    alert('Error al cargar las zonas');
  } finally {
    loading.value = false;
  }
};

const mostrarModalCrear = () => {
  modoEdicion.value = false;
  form.value = {
    id_zona: null,
    zona: ''
  };
  showModal.value = true;
};

const mostrarModalEditar = (zona) => {
  modoEdicion.value = true;
  form.value = {
    id_zona: zona.id_zona,
    zona: zona.zona
  };
  showModal.value = true;
};

const cerrarModal = () => {
  showModal.value = false;
  form.value = { id_zona: null, zona: '' };
};

const guardarZona = async () => {
  if (!form.value.id_zona || !form.value.zona) {
    alert('Por favor complete todos los campos requeridos');
    return;
  }

  guardando.value = true;
  try {
    const operacion = modoEdicion.value ? 'sp_zonas_update' : 'sp_zonas_create';
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_zona', Valor: parseInt(form.value.id_zona) },
          { Nombre: 'p_zona', Valor: form.value.zona }
        ]
      }
    });

    if (response.data.eResponse?.success) {
      const result = response.data.eResponse.data.result;
      if (result && result.length > 0 && result[0].message) {
        if (result[0].message.includes('ERROR')) {
          alert(result[0].message);
        } else {
          alert(result[0].message);
          cerrarModal();
          cargarZonas();
        }
      } else {
        alert(modoEdicion.value ? 'Zona actualizada exitosamente' : 'Zona creada exitosamente');
        cerrarModal();
        cargarZonas();
      }
    } else {
      alert('Error al guardar la zona');
    }
  } catch (error) {
    console.error('Error:', error);
    alert('Error al guardar la zona: ' + error.message);
  } finally {
    guardando.value = false;
  }
};

const confirmarEliminar = (zona) => {
  zonaEliminar.value = zona;
  showDeleteModal.value = true;
};

const cerrarModalEliminar = () => {
  showDeleteModal.value = false;
  zonaEliminar.value = null;
};

const eliminarZona = async () => {
  if (!zonaEliminar.value) return;

  eliminando.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_zonas_delete',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_zona', Valor: parseInt(zonaEliminar.value.id_zona) }
        ]
      }
    });

    if (response.data.eResponse?.success) {
      const result = response.data.eResponse.data.result;
      if (result && result.length > 0) {
        if (result[0].success) {
          alert(result[0].message);
          cerrarModalEliminar();
          cargarZonas();
        } else {
          alert(result[0].message);
        }
      }
    } else {
      alert('Error al eliminar la zona');
    }
  } catch (error) {
    console.error('Error:', error);
    alert('Error al eliminar la zona: ' + error.message);
  } finally {
    eliminando.value = false;
  }
};

const mostrarAyuda = () => {
  alert('Catálogo de Zonas Geográficas\n\nAdministre las zonas geográficas utilizadas para clasificar los mercados municipales.\n\n- Crear: Agregue nuevas zonas\n- Editar: Modifique el nombre de zonas existentes\n- Eliminar: Elimine zonas que no estén en uso\n\nNota: No se pueden eliminar zonas que estén asignadas a mercados.');
};
</script>

<style scoped>
@import '@/styles/municipal-theme.css';

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1050;
}

.modal-dialog {
  max-width: 500px;
  width: 90%;
}

.modal-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.modal-header {
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top-left-radius: 8px;
  border-top-right-radius: 8px;
}

.modal-header.municipal-bg-primary {
  background-color: #4a5f7f;
  color: white;
}

.modal-header.municipal-bg-danger {
  background-color: #dc3545;
  color: white;
}

.modal-title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 500;
}

.btn-close {
  background: transparent;
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  opacity: 0.8;
}

.btn-close:hover {
  opacity: 1;
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #dee2e6;
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

.form-text {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
}

.text-muted {
  color: #6c757d;
}

.text-danger {
  color: #dc3545;
}
</style>
