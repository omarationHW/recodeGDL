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
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-primary" @click="cargarZonas">
          <font-awesome-icon icon="sync-alt" /> Actualizar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <div v-if="zonas.length === 0" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No hay zonas registradas.
      </div>

      <div v-if="zonas.length > 0" class="municipal-card">
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
    <Modal
      v-if="showModal"
      :show="showModal"
      :title="modoEdicion ? 'Editar Zona' : 'Nueva Zona'"
      size="md"
      @close="cerrarModal">
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

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
          <font-awesome-icon icon="times" /> Cancelar
        </button>
        <button type="button" class="btn-municipal-primary" @click="guardarZona" :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Guardar' }}
        </button>
      
  <DocumentationModal :show="showAyuda" :component-name="'ZonasMercados'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - ZonasMercados'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'ZonasMercados'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - ZonasMercados'" @close="showDocumentacion = false" />
</template>
    </Modal>

    <!-- Modal Confirmar Eliminación -->
    <Modal
      v-if="showDeleteModal"
      :show="showDeleteModal"
      title="Confirmar Eliminación"
      size="md"
      @close="cerrarModalEliminar">
      <template #body>
        <p>¿Está seguro que desea eliminar la zona <strong>{{ zonaEliminar?.zona }}</strong>?</p>
        <p class="text-danger">Esta acción no se puede deshacer.</p>
      </template>

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="cerrarModalEliminar">
          <font-awesome-icon icon="times" /> Cancelar
        </button>
        <button type="button" class="btn-municipal-danger" @click="eliminarZona" :disabled="eliminando">
          <font-awesome-icon :icon="eliminando ? 'spinner' : 'trash'" :spin="eliminando" />
          {{ eliminando ? 'Eliminando...' : 'Eliminar' }}
        </button>
      </template>
    </Modal>
  </div>
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
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import Modal from '@/components/common/Modal.vue';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


// Composables
const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();

const zonas = ref([]);
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
  showLoading('Cargando zonas...');
  try {
    const response = await apiService.execute(
          'sp_zonas_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        );

    if (response?.success && response?.data?.result) {
      zonas.value = response.data.result;
      showToast(`Se cargaron ${zonas.value.length} zonas`, 'success');
    } else {
      zonas.value = [];
      showToast('No se encontraron zonas', 'warning');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al cargar las zonas', 'error');
  } finally {
    hideLoading();
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
    showToast('Por favor complete todos los campos requeridos', 'warning');
    return;
  }

  guardando.value = true;
  showLoading(modoEdicion.value ? 'Actualizando zona...' : 'Guardando zona...');
  try {
    const operacion = modoEdicion.value ? 'sp_zonas_update' : 'sp_zonas_create';
    const response = await apiService.execute(
      operacion,
      'mercados',
      [
        { nombre: 'p_id_zona', valor: parseInt(form.value.id_zona), tipo: 'integer' },
        { nombre: 'p_zona', valor: form.value.zona, tipo: 'string' }
      ],
      '',
      null,
      'publico'
    );

    if (response?.success) {
      const result = response.data.result;
      if (result && result.length > 0 && result[0].message) {
        if (result[0].message.includes('ERROR')) {
          showToast(result[0].message, 'error');
        } else {
          showToast(result[0].message, 'success');
          cerrarModal();
          cargarZonas();
        }
      } else {
        showToast(modoEdicion.value ? 'Zona actualizada exitosamente' : 'Zona creada exitosamente', 'success');
        cerrarModal();
        cargarZonas();
      }
    } else {
      showToast('Error al guardar la zona', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al guardar la zona: ' + error.message, 'error');
  } finally {
    guardando.value = false;
    hideLoading();
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
  showLoading('Eliminando zona...');
  try {
    const response = await apiService.execute(
          'sp_zonas_delete',
          'mercados',
          [
          { nombre: 'p_id_zona', valor: parseInt(zonaEliminar.value.id_zona) }
        ],
          '',
          null,
          'publico'
        );

    if (response?.success) {
      const result = response.data.result;
      if (result && result.length > 0) {
        if (result[0].success) {
          showToast(result[0].message, 'success');
          cerrarModalEliminar();
          cargarZonas();
        } else {
          showToast(result[0].message, 'error');
        }
      }
    } else {
      showToast('Error al eliminar la zona', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al eliminar la zona: ' + error.message, 'error');
  } finally {
    eliminando.value = false;
    hideLoading();
  }
};

const mostrarAyuda = () => {
  showToast('Catálogo de Zonas Geográficas\n\nAdministre las zonas geográficas utilizadas para clasificar los mercados municipales.\n\n- Crear: Agregue nuevas zonas\n- Editar: Modifique el nombre de zonas existentes\n- Eliminar: Elimine zonas que no estén en uso\n\nNota: No se pueden eliminar zonas que estén asignadas a mercados.', 'info');
};
</script>
