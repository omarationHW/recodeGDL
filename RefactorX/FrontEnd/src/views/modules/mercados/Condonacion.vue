<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="hand-holding-usd" />
      </div>
      <div class="module-view-info">
        <h1>Condonación de Adeudos</h1>
        <p>Mercados - Gestión de Condonaciones de Adeudos</p>
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
        </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Local -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarLocal">
            <div class="row">
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Recaudadora *</label>
                <select class="municipal-form-control" v-model="form.oficina" @change="onOficinaChange" required>
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                   {{ rec.id_rec }} - {{ rec.recaudadora }}
                  </option>
                </select>
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Mercado *</label>
                <select class="municipal-form-control" v-model="form.num_mercado" :disabled="!form.oficina" required>
                  <option value="">Seleccione...</option>
                  <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                  </option>
                </select>
              </div>
              <div class="col-md-2 mb-3">
                <label class="municipal-form-label">Categoría *</label>
                <select class="municipal-form-control" v-model="form.categoria" required>
                  <option value="">Seleccione...</option>
                  <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                    {{ cat.categoria }} - {{ cat.descripcion }}
                  </option>
                </select>
              </div>
              <div class="col-md-1 mb-3">
                <label class="municipal-form-label">Sección *</label>
                <input type="text" class="municipal-form-control" v-model="form.seccion" maxlength="2" required />
              </div>
              <div class="col-md-1 mb-3">
                <label class="municipal-form-label">Local *</label>
                <input type="number" class="municipal-form-control" v-model.number="form.local" required min="1" />
              </div>
              <div class="col-md-1 mb-3">
                <label class="municipal-form-label">Letra</label>
                <input type="text" class="municipal-form-control" v-model="form.letra_local" maxlength="1" />
              </div>
              <div class="col-md-1 mb-3">
                <label class="municipal-form-label">Bloque</label>
                <input type="text" class="municipal-form-control" v-model="form.bloque" maxlength="1" />
              </div>
            </div>
            <button type="submit" class="btn-municipal-primary" :disabled="loading">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </form>

          <!-- Datos del Local -->
          <div v-if="localData" class="mt-3 p-3 bg-light rounded">
            <h6>Datos del Local</h6>
            <div class="row">
              <div class="col-md-6">
                <p><strong>Nombre:</strong> {{ localData.nombre }}</p>
                <p><strong>Descripción:</strong> {{ localData.descripcion_local }}</p>
              </div>
              <div class="col-md-6">
                <p><strong>Superficie:</strong> {{ localData.superficie }}</p>
                <p><strong>Clave Cuota:</strong> {{ localData.clave_cuota }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Adeudos a Condonar -->
      <div v-if="localData" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="file-invoice-dollar" />
            Adeudos a Condonar
            <span v-if="adeudos.length > 0" class="badge bg-warning ms-2">{{ adeudos.length }}</span>
          </h5>
          <button class="btn-municipal-primary btn-sm ms-auto" @click="listarAdeudos" :disabled="loading">
            <font-awesome-icon icon="sync" />
            Listar
          </button>
        </div>
        <div class="municipal-card-body">
          <div v-if="adeudos.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th style="width: 40px;"></th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Importe</th>
                  <th>Detalle</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(a, idx) in paginatedAdeudos" :key="idx">
                  <td><input type="checkbox" class="form-check-input" v-model="a.selected" /></td>
                  <td>{{ a.axo }}</td>
                  <td>{{ a.periodo }}</td>
                  <td>{{ formatCurrency(a.importe) }}</td>
                  <td>{{ a.detalle }}</td>
                </tr>
              </tbody>
            </table>

            <!-- Controles de paginación para adeudos -->
            <div v-if="adeudos.length > itemsPerPageAd" class="pagination-controls mt-3">
              <div class="pagination-info">
                <span class="text-muted">
                  Mostrando {{ ((currentPageAd - 1) * itemsPerPageAd) + 1 }}
                  a {{ Math.min(currentPageAd * itemsPerPageAd, adeudos.length) }}
                  de {{ adeudos.length }} registros
                </span>
              </div>

              <div class="pagination-size">
                <label class="municipal-form-label me-2">Registros por página:</label>
                <select
                  class="municipal-form-control form-control-sm"
                  :value="itemsPerPageAd"
                  @change="changePageSizeAd($event.target.value)"
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
                  @click="goToPageAd(1)"
                  :disabled="currentPageAd === 1"
                  title="Primera página"
                >
                  <font-awesome-icon icon="angle-double-left" />
                </button>

                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="goToPageAd(currentPageAd - 1)"
                  :disabled="currentPageAd === 1"
                  title="Página anterior"
                >
                  <font-awesome-icon icon="angle-left" />
                </button>

                <button
                  v-for="page in visiblePagesAd"
                  :key="page"
                  class="btn-sm"
                  :class="page === currentPageAd ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                  @click="goToPageAd(page)"
                >
                  {{ page }}
                </button>

                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="goToPageAd(currentPageAd + 1)"
                  :disabled="currentPageAd === totalPagesAd"
                  title="Página siguiente"
                >
                  <font-awesome-icon icon="angle-right" />
                </button>

                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="goToPageAd(totalPagesAd)"
                  :disabled="currentPageAd === totalPagesAd"
                  title="Última página"
                >
                  <font-awesome-icon icon="angle-double-right" />
                </button>
              </div>
            </div>
            <div class="mt-3">
              <div class="row align-items-end">
                <div class="col-md-4">
                  <label class="municipal-form-label">Oficio (LLL/9999/9999) *</label>
                  <input type="text" class="municipal-form-control" v-model="oficio" maxlength="13" placeholder="LLL/9999/9999" />
                </div>
                <div class="col-md-4">
                  <button class="btn-municipal-primary" @click="condonarSeleccionados" :disabled="loading">
                    <font-awesome-icon icon="check" />
                    Condonar Seleccionados
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div v-else class="text-center py-3 text-muted">
            <p>No hay adeudos pendientes</p>
          </div>
        </div>
      </div>

      <!-- Condonados -->
      <div v-if="localData" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="history" />
            Condonaciones Realizadas
            <span v-if="condonados.length > 0" class="badge bg-info ms-2">{{ condonados.length }}</span>
          </h5>
          <button class="btn-municipal-primary btn-sm ms-auto" @click="listarCondonados" :disabled="loading">
            <font-awesome-icon icon="sync" />
            Listar
          </button>
        </div>
        <div class="municipal-card-body">
          <div v-if="condonados.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th style="width: 40px;"></th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Importe</th>
                  <th>Observación</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(c, idx) in paginatedCondonados" :key="idx">
                  <td><input type="checkbox" class="form-check-input" v-model="c.selected" /></td>
                  <td>{{ c.axo }}</td>
                  <td>{{ c.periodo }}</td>
                  <td>{{ formatCurrency(c.importe) }}</td>
                  <td>{{ c.observacion }}</td>
                </tr>
              </tbody>
            </table>

            <!-- Controles de paginación para condonados -->
            <div v-if="condonados.length > itemsPerPageCo" class="pagination-controls mt-3">
              <div class="pagination-info">
                <span class="text-muted">
                  Mostrando {{ ((currentPageCo - 1) * itemsPerPageCo) + 1 }}
                  a {{ Math.min(currentPageCo * itemsPerPageCo, condonados.length) }}
                  de {{ condonados.length }} registros
                </span>
              </div>

              <div class="pagination-size">
                <label class="municipal-form-label me-2">Registros por página:</label>
                <select
                  class="municipal-form-control form-control-sm"
                  :value="itemsPerPageCo"
                  @change="changePageSizeCo($event.target.value)"
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
                  @click="goToPageCo(1)"
                  :disabled="currentPageCo === 1"
                  title="Primera página"
                >
                  <font-awesome-icon icon="angle-double-left" />
                </button>

                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="goToPageCo(currentPageCo - 1)"
                  :disabled="currentPageCo === 1"
                  title="Página anterior"
                >
                  <font-awesome-icon icon="angle-left" />
                </button>

                <button
                  v-for="page in visiblePagesCo"
                  :key="page"
                  class="btn-sm"
                  :class="page === currentPageCo ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                  @click="goToPageCo(page)"
                >
                  {{ page }}
                </button>

                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="goToPageCo(currentPageCo + 1)"
                  :disabled="currentPageCo === totalPagesCo"
                  title="Página siguiente"
                >
                  <font-awesome-icon icon="angle-right" />
                </button>

                <button
                  class="btn-municipal-secondary btn-sm"
                  @click="goToPageCo(totalPagesCo)"
                  :disabled="currentPageCo === totalPagesCo"
                  title="Última página"
                >
                  <font-awesome-icon icon="angle-double-right" />
                </button>
              </div>
            </div>
            <div class="mt-3">
              <button class="btn-municipal-warning" @click="deshacerCondonacion" :disabled="loading">
                <font-awesome-icon icon="undo" />
                Deshacer Condonación
              </button>
            </div>
          </div>
          <div v-else class="text-center py-3 text-muted">
            <p>No hay condonaciones registradas</p>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'Condonacion'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - Condonacion'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'Condonacion'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - Condonacion'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading();

const router = useRouter();

// State
const loading = ref(false);
const recaudadoras = ref([]);
const mercados = ref([]);
const categorias = ref([]);
const form = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: ''
});
const localData = ref(null);
const adeudos = ref([]);
const condonados = ref([]);
const oficio = ref('');

// Paginación
const currentPageAd = ref(1);
const itemsPerPageAd = ref(10);
const currentPageCo = ref(1);
const itemsPerPageCo = ref(10);

// Helpers
const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0);
};

// Paginación adeudos
const totalPagesAd = computed(() => Math.ceil(adeudos.value.length / itemsPerPageAd.value));
const paginatedAdeudos = computed(() => {
  const start = (currentPageAd.value - 1) * itemsPerPageAd.value;
  const end = start + itemsPerPageAd.value;
  return adeudos.value.slice(start, end);
});
const visiblePagesAd = computed(() => {
  const pages = [];
  const maxVisible = 5;
  let startPage = Math.max(1, currentPageAd.value - Math.floor(maxVisible / 2));
  let endPage = Math.min(totalPagesAd.value, startPage + maxVisible - 1);
  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1);
  }
  for (let i = startPage; i <= endPage; i++) {
    pages.push(i);
  }
  return pages;
});

// Paginación condonados
const totalPagesCo = computed(() => Math.ceil(condonados.value.length / itemsPerPageCo.value));
const paginatedCondonados = computed(() => {
  const start = (currentPageCo.value - 1) * itemsPerPageCo.value;
  const end = start + itemsPerPageCo.value;
  return condonados.value.slice(start, end);
});
const visiblePagesCo = computed(() => {
  const pages = [];
  const maxVisible = 5;
  let startPage = Math.max(1, currentPageCo.value - Math.floor(maxVisible / 2));
  let endPage = Math.min(totalPagesCo.value, startPage + maxVisible - 1);
  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1);
  }
  for (let i = startPage; i <= endPage; i++) {
    pages.push(i);
  }
  return pages;
});

const goToPageAd = (page) => {
  if (page >= 1 && page <= totalPagesAd.value) {
    currentPageAd.value = page;
  }
};

const changePageSizeAd = (newSize) => {
  itemsPerPageAd.value = parseInt(newSize);
  currentPageAd.value = 1;
};

const goToPageCo = (page) => {
  if (page >= 1 && page <= totalPagesCo.value) {
    currentPageCo.value = page;
  }
};

const changePageSizeCo = (newSize) => {
  itemsPerPageCo.value = parseInt(newSize);
  currentPageCo.value = 1;
};

const showToast = (message, type) => {
  Swal.fire({
    toast: true,
    position: 'top-end',
    icon: type,
    title: message,
    showConfirmButton: false,
    timer: 3000
  });
};// Buscar Local
async function buscarLocal() {
  loading.value = true;
  localData.value = null;
  adeudos.value = [];
  condonados.value = [];

  try {
    const response = await apiService.execute(
          'sp_condonacion_buscar_local',
          'mercados',
          [
          { nombre: 'p_oficina', valor: form.value.oficina, tipo: 'integer' },
          { nombre: 'p_num_mercado', valor: form.value.num_mercado, tipo: 'integer' },
          { nombre: 'p_categoria', valor: form.value.categoria, tipo: 'integer' },
          { nombre: 'p_seccion', valor: form.value.seccion },
          { nombre: 'p_local', valor: form.value.local, tipo: 'integer' },
          { nombre: 'p_letra_local', valor: form.value.letra_local || null },
          { nombre: 'p_bloque', valor: form.value.bloque || null }
        ],
          '',
          null,
          'publico'
        );

    if (response.success) {
      const result = response.data.result;
      if (result && result.length > 0) {
        localData.value = result[0];
        showToast('Local encontrado', 'success');
        listarAdeudos();
        listarCondonados();
      } else {
        showToast('Local no encontrado', 'warning');
      }
    } else {
      showToast(response.message || 'Error al buscar', 'error');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al buscar local', 'error');
  } finally {
    loading.value = false;
  }
}

// Listar Adeudos
async function listarAdeudos() {
  if (!localData.value) return;
  loading.value = true;

  try {
    const response = await apiService.execute(
          'sp_condonacion_listar_adeudos',
          'mercados',
          [
          { nombre: 'p_id_local', valor: localData.value.id_local, tipo: 'integer' }
        ],
          '',
          null,
          'publico'
        );

    if (response.success) {
      adeudos.value = (response.data.result || []).map(a => ({ ...a, selected: false }));
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    loading.value = false;
  }
}

// Condonar Seleccionados
async function condonarSeleccionados() {
  if (!oficio.value || oficio.value.trim().length < 10) {
    showToast('Ingrese un oficio válido (mín. 10 caracteres)', 'warning');
    return;
  }

  const seleccionados = adeudos.value.filter(a => a.selected);
  if (seleccionados.length === 0) {
    showToast('Seleccione al menos un adeudo', 'warning');
    return;
  }

  const result = await Swal.fire({
    title: '¿Condonar adeudos?',
    text: `Se condonarán ${seleccionados.length} adeudo(s)`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, condonar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  loading.value = true;
  let exitosos = 0;

  try {
    for (const a of seleccionados) {
      const response = await apiService.execute(
          'sp_condonacion_condonar',
          'mercados',
          [
            { nombre: 'p_id_local', valor: localData.value.id_local, tipo: 'integer' },
            { nombre: 'p_axo', valor: a.axo, tipo: 'integer' },
            { nombre: 'p_periodo', valor: a.periodo, tipo: 'integer' },
            { nombre: 'p_importe', valor: a.importe, tipo: 'numeric' },
            { nombre: 'p_oficio', valor: oficio.value }
          ],
          '',
          null,
          'publico'
        );

      if (response.success) {
        exitosos++;
      }
    }

    showToast(`${exitosos} adeudo(s) condonado(s)`, 'success');
    listarAdeudos();
    listarCondonados();
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al condonar', 'error');
  } finally {
    loading.value = false;
  }
}

// Listar Condonados
async function listarCondonados() {
  if (!localData.value) return;
  loading.value = true;

  try {
    const response = await apiService.execute(
          'sp_condonacion_listar_condonados',
          'mercados',
          [
          { nombre: 'p_id_local', valor: localData.value.id_local, tipo: 'integer' }
        ],
          '',
          null,
          'publico'
        );

    if (response.success) {
      condonados.value = (response.data.result || []).map(c => ({ ...c, selected: false }));
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    loading.value = false;
  }
}

// Deshacer Condonación
async function deshacerCondonacion() {
  const seleccionados = condonados.value.filter(c => c.selected);
  if (seleccionados.length === 0) {
    showToast('Seleccione al menos una condonación', 'warning');
    return;
  }

  const result = await Swal.fire({
    title: '¿Deshacer condonación?',
    text: `Se deshará ${seleccionados.length} condonación(es)`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    confirmButtonText: 'Sí, deshacer',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  loading.value = true;
  let exitosos = 0;

  try {
    for (const c of seleccionados) {
      const response = await apiService.execute(
          'sp_condonacion_deshacer',
          'mercados',
          [
            { nombre: 'p_id_cancelacion', valor: c.id_cancelacion, tipo: 'integer' },
            { nombre: 'p_id_local', valor: c.id_local, tipo: 'integer' },
            { nombre: 'p_axo', valor: c.axo, tipo: 'integer' },
            { nombre: 'p_periodo', valor: c.periodo, tipo: 'integer' },
            { nombre: 'p_importe', valor: c.importe, tipo: 'numeric' }
          ],
          '',
          null,
          'publico'
        );

      if (response.success) {
        exitosos++;
      }
    }

    showToast(`${exitosos} condonación(es) deshecha(s)`, 'success');
    listarAdeudos();
    listarCondonados();
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al deshacer', 'error');
  } finally {
    loading.value = false;
  }
}

// Cargar Recaudadoras
async function fetchRecaudadoras() {
  showLoading('Cargando Condonación', 'Preparando oficinas recaudadoras...');
  try {
    const response = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        );
    if (response.success) {
      recaudadoras.value = response.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
  } finally {
    hideLoading();
  }
}

// Cargar Categorías
async function fetchCategorias() {
  try {
    const response = await apiService.execute(
          'sp_categoria_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        );
    if (response.success) {
      categorias.value = response.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar categorías:', error);
  }
}

// Cambio de Oficina
async function onOficinaChange() {
  form.value.num_mercado = '';
  mercados.value = [];
  if (!form.value.oficina) return;

  try {
    const response = await apiService.execute(
          'sp_consulta_locales_get_mercados',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(form.value.oficina), tipo: 'integer' }
        ],
          '',
          null,
          'publico'
        );
    if (response.success) {
      mercados.value = response.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
  }
}


// Ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Condonaciones',
    html: `
      <div style="text-align: left;">
        <h6>Funcionalidad del mÃ³dulo:</h6>
        <p>Este mÃ³dulo permite gestionar las condonaciones de adeudos.</p>
        <h6>Instrucciones:</h6>
        <ol>
          <li>Seleccione el local y el perÃ­odo a condonar
          <li>Indique el porcentaje o monto de condonaciÃ³n
          <li>Las condonaciones requieren autorizaciÃ³n y quedan registradas en el historial</li>
        </ol>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}

onMounted(() => {
  fetchRecaudadoras();
  fetchCategorias();
});
</script>
