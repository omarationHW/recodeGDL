<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Reporte Catálogo de Mercados</h1>
        <p>Mercados - Reporte y Administración del Catálogo</p>
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
        
        <button class="btn-municipal-primary" @click="showModal('create')">
          <font-awesome-icon icon="plus" />
          Agregar
        </button>
        <button class="btn-municipal-primary" @click="fetchData" :disabled="loading">
          <font-awesome-icon icon="sync" />
          Refrescar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Tabla de Mercados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Catálogo de Mercados Municipales
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
                  <th>Tipo Emisión</th>
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
                  <td>{{ row.id_zona || '-' }}</td>
                  <td>{{ emisionLabel(row.tipo_emision) }}</td>
                  <td>
                    <span :class="row.vigencia === 'A' ? 'badge bg-success' : 'badge bg-danger'">
                      {{ row.vigencia === 'A' ? 'Activo' : 'Baja' }}
                    </span>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary" @click.stop="showModal('update', row)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-municipal-danger" @click.stop="deleteRow(row)" title="Eliminar">
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
            <p>No hay mercados registrados</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <Modal
      :show="showFormModal"
      :title="formMode === 'create' ? 'Agregar Mercado' : 'Modificar Mercado'"
      size="md"
      :loading="loading"
      show-default-footer
      :show-cancel-button="true"
      :show-confirm-button="true"
      cancel-text="Cancelar"
      confirm-text="Guardar"
      confirm-button-class="btn-success"
      @close="closeModal"
      @confirm="submitForm"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon :icon="formMode === 'create' ? 'plus' : 'edit'" class="me-2" />
          {{ formMode === 'create' ? 'Agregar Mercado' : 'Modificar Mercado' }}
        </h5>
      
  <DocumentationModal :show="showAyuda" :component-name="'RptCatalogoMerc'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - RptCatalogoMerc'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'RptCatalogoMerc'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - RptCatalogoMerc'" @close="showDocumentacion = false" />
</template>

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
            <label class="municipal-form-label">Zona</label>
            <input type="number" class="municipal-form-control" v-model.number="form.id_zona" min="0" />
          </div>
          <div class="col-md-6 mb-3">
            <label class="municipal-form-label">Tipo Emisión</label>
            <select class="municipal-form-control" v-model="form.tipo_emision">
              <option value="M">Masiva</option>
              <option value="D">Diskette</option>
              <option value="B">Baja</option>
            </select>
          </div>
        </div>
      </form>
    </Modal>
  </div>
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, onMounted } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import Modal from '@/components/common/Modal.vue';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const router = useRouter();
const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();

// State
const rows = ref([]);
const selectedRow = ref(null);
const loading = ref(false);
const showFormModal = ref(false);
const formMode = ref('create');
const form = ref({
  id_mercado: null,
  oficina: '',
  num_mercado_nvo: '',
  descripcion: '',
  id_zona: '',
  tipo_emision: 'M'
});// Helper para tipo emisión
const emisionLabel = (val) => {
  if (val === 'M') return 'Masiva';
  if (val === 'D') return 'Diskette';
  if (val === 'B') return 'Baja';
  return val || '-';
};

// Cargar datos
async function fetchData() {
  showLoading('Cargando catálogo de mercados...', 'Por favor espere');
  loading.value = true;
  try {
    const response = await apiService.execute(
          'sp_rpt_catalogo_mercados_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        );

    if (response.success) {
      rows.value = response.data.result || [];
      showToast('Datos cargados correctamente', 'success');
    } else {
      showToast(response.message || 'Error al cargar datos', 'error');
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
      id_zona: '',
      tipo_emision: 'M'
    };
  } else if (row) {
    form.value = {
      id_mercado: row.id_mercado,
      oficina: row.oficina,
      num_mercado_nvo: row.num_mercado_nvo,
      descripcion: row.descripcion,
      id_zona: row.id_zona || '',
      tipo_emision: row.tipo_emision || 'M'
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

  showLoading('Guardando mercado...', 'Por favor espere');
  loading.value = true;
  try {
    const sp = formMode.value === 'create' ? 'sp_rpt_catalogo_mercados_create' : 'sp_rpt_catalogo_mercados_update';
    const params = formMode.value === 'create'
      ? [
          { nombre: 'p_oficina', valor: form.value.oficina, tipo: 'integer' },
          { nombre: 'p_num_mercado_nvo', valor: form.value.num_mercado_nvo, tipo: 'integer' },
          { nombre: 'p_descripcion', valor: form.value.descripcion },
          { nombre: 'p_id_zona', valor: form.value.id_zona || null, tipo: 'integer' },
          { nombre: 'p_tipo_emision', valor: form.value.tipo_emision }
        ]
      : [
          { nombre: 'p_id_mercado', valor: form.value.id_mercado, tipo: 'integer' },
          { nombre: 'p_descripcion', valor: form.value.descripcion },
          { nombre: 'p_id_zona', valor: form.value.id_zona || null, tipo: 'integer' },
          { nombre: 'p_tipo_emision', valor: form.value.tipo_emision }
        ];

    const response = await apiService.execute(sp, 'mercados', params, '', null, 'publico');

    if (response.success) {
      showToast(formMode.value === 'create' ? 'Mercado creado correctamente' : 'Mercado actualizado correctamente', 'success');
      closeModal();
      fetchData();
    } else {
      showToast(response.message || 'Error al guardar', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al guardar mercado', 'error');
  } finally {
    loading.value = false;
    hideLoading();
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

  showLoading('Eliminando mercado...', 'Por favor espere');
  loading.value = true;
  try {
    const response = await apiService.execute(
          'sp_rpt_catalogo_mercados_delete',
          'mercados',
          [
          { nombre: 'p_id_mercado', valor: row.id_mercado, tipo: 'integer' }
        ],
          '',
          null,
          'publico'
        );

    if (response.success) {
      showToast('Mercado eliminado correctamente', 'success');
      fetchData();
    } else {
      showToast(response.message || 'Error al eliminar', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al eliminar mercado', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}


// Ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Reporte de CatÃ¡logo de Mercados',
    html: `
      <div style="text-align: left;">
        <h6>Funcionalidad del mÃ³dulo:</h6>
        <p>Este mÃ³dulo genera reportes del catÃ¡logo de mercados.</p>
        <h6>Instrucciones:</h6>
        <ol>
          <li>Seleccione los filtros deseados
          <li>Puede exportar a Excel o imprimir
          <li>El reporte incluye todos los mercados activos y de baja</li>
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
