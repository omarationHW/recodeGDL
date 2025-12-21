<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store-alt" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Pagos por Locales</h1>
        <p>Mercados - Registro de Pagos de Renta por Local</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros principales -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header" @click="toggleFiltros" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFiltros ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>
        <div v-show="showFiltros" class="municipal-card-body">
          <div class="row">
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Recaudadora <span class="text-danger">*</span></label>
              <select class="municipal-form-control" v-model="filtros.oficina" @change="onOficinaChange"
                :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Mercado <span class="text-danger">*</span></label>
              <select class="municipal-form-control" v-model="filtros.mercado" @change="onMercadoChange"
                :disabled="loading || !filtros.oficina">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Categoría <small>(filtro opcional)</small></label>
              <select class="municipal-form-control" v-model="filtros.categoria" :disabled="loading">
                <option value="">Todas</option>
                <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                  {{ cat.categoria }} - {{ cat.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Sección <small>(filtro opcional)</small></label>
              <select class="municipal-form-control" v-model="filtros.seccion" :disabled="loading">
                <option value="">Todas</option>
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                  {{ sec.seccion }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Local <small>(filtro opcional)</small></label>
              <input type="number" class="municipal-form-control" v-model.number="filtros.local"
                :disabled="loading" min="1" placeholder="Todos" />
            </div>
          </div>
          <div class="d-flex justify-content-end gap-2">
            <button class="btn-municipal-primary" @click="buscarLocales"
              :disabled="!puedesBuscarLocales || loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              <font-awesome-icon icon="search" v-if="!loading" />
              Buscar Locales
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Listado de Locales -->
      <div v-if="locales.length > 0" class="municipal-card mb-3">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Locales Encontrados
          </h5>
          <div class="header-right">
            <span class="badge-purple">
              {{ locales.length }} {{ locales.length === 1 ? 'local' : 'locales' }}
            </span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Local</th>
                  <th>Recaudadora</th>
                  <th>Mercado</th>
                  <th>Categoría</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th class="text-center">Estado</th>
                  <th class="text-center">Acción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="local in paginatedLocales" :key="local.id_local"
                  :class="{ 'table-active': localSeleccionado?.id_local === local.id_local }">
                  <td><strong class="text-primary">{{ local.id_local }}</strong></td>
                  <td>{{ local.oficina }}</td>
                  <td>{{ local.num_mercado }}</td>
                  <td>{{ local.categoria }}</td>
                  <td>{{ local.seccion }}</td>
                  <td>{{ local.local }}</td>
                  <td>{{ local.letra_local || '-' }}</td>
                  <td>{{ local.bloque || '-' }}</td>
                  <td class="text-center">
                    <span v-if="local.tiene_adeudo" class="badge bg-danger">
                      <font-awesome-icon icon="exclamation-circle" />
                      Con adeudo
                    </span>
                    <span v-else class="badge bg-success">
                      <font-awesome-icon icon="check-circle" />
                      Al corriente
                    </span>
                  </td>
                  <td class="text-center">
                    <button class="btn-municipal-primary btn-sm"
                      @click="seleccionarLocal(local)"
                      :disabled="loading">
                      <font-awesome-icon icon="hand-pointer" />
                      Seleccionar
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="locales.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPageLocales - 1) * itemsPerPageLocales) + 1 }}
                a {{ Math.min(currentPageLocales * itemsPerPageLocales, locales.length) }}
                de {{ locales.length }} locales
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select class="municipal-form-control form-control-sm" :value="itemsPerPageLocales"
                @change="changePageSizeLocales($event.target.value)" style="width: auto; display: inline-block;">
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPageLocales(1)"
                :disabled="currentPageLocales === 1">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPageLocales(currentPageLocales - 1)"
                :disabled="currentPageLocales === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <button v-for="page in visiblePagesLocales" :key="page" class="btn-sm"
                :class="page === currentPageLocales ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPageLocales(page)">
                {{ page }}
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPageLocales(currentPageLocales + 1)"
                :disabled="currentPageLocales === totalPagesLocales">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPageLocales(totalPagesLocales)"
                :disabled="currentPageLocales === totalPagesLocales">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Adeudos del Local Seleccionado -->
      <div v-if="localSeleccionado && adeudos.length > 0" class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="file-invoice-dollar" />
            Adeudos del Local: {{ localSeleccionado.id_local }}
            <span class="badge bg-danger ms-2">{{ adeudos.length }} adeudos</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Info del local -->
          <div class="alert alert-info mb-3">
            <div class="row">
              <div class="col-md-4">
                <strong>Local:</strong> {{ localSeleccionado.oficina }}-{{ localSeleccionado.num_mercado }}-{{ localSeleccionado.categoria }}-{{ localSeleccionado.seccion }}-{{ localSeleccionado.local }}
              </div>
              <div class="col-md-4">
                <strong>Letra:</strong> {{ localSeleccionado.letra_local || '-' }}
              </div>
              <div class="col-md-4">
                <strong>Bloque:</strong> {{ localSeleccionado.bloque || '-' }}
              </div>
            </div>
          </div>

          <div class="table-responsive">
            <table class="municipal-table table-sm">
              <thead>
                <tr>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Renta</th>
                  <th style="width: 150px;">Partida</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, idx) in adeudos" :key="`${adeudo.id_local}-${adeudo.axo}-${adeudo.periodo}`">
                  <td>{{ adeudo.axo }}</td>
                  <td>{{ getNombreMes(adeudo.periodo) }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(adeudo.importe) }}</strong></td>
                  <td>
                    <input type="text" class="municipal-form-control" v-model="adeudo.partida"
                      placeholder="Núm. partida" maxlength="20"
                      style="width: 140px; height: 32px; font-size: 0.875rem;" />
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-secondary">
                  <td colspan="2" class="text-end"><strong>TOTAL:</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalAdeudos) }}</strong></td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Datos del Pago -->
          <div class="row mt-4">
            <div class="col-md-12">
              <h6 class="text-primary mb-3">
                <font-awesome-icon icon="credit-card" />
                Datos del Pago
              </h6>
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Fecha de Pago <span class="text-danger">*</span></label>
              <input type="date" class="municipal-form-control" v-model="formPago.fecha_pago" :disabled="loading" />
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Oficina Pago <span class="text-danger">*</span></label>
              <select class="municipal-form-control" v-model="formPago.oficina_pago" @change="onOficinaPagoChange"
                :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Caja <span class="text-danger">*</span></label>
              <select class="municipal-form-control" v-model="formPago.caja_pago"
                :disabled="loading || !formPago.oficina_pago">
                <option value="">Seleccione...</option>
                <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">
                  {{ caja.caja }}
                </option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Operación <span class="text-danger">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="formPago.operacion_pago"
                :disabled="loading" min="1" />
            </div>
          </div>

          <div class="d-flex justify-content-end gap-2">
            <button class="btn-municipal-success" @click="grabarPagos" :disabled="!hayPagosValidos || loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              <font-awesome-icon icon="save" v-if="!loading" />
              Grabar Pagos
            </button>
            <button class="btn-municipal-secondary" @click="cancelarSeleccion" :disabled="loading">
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-if="!loading && locales.length === 0 && !localSeleccionado" class="municipal-card">
        <div class="municipal-card-body text-center py-5 text-muted">
          <font-awesome-icon icon="inbox" size="3x" class="mb-3" style="opacity: 0.3;" />
          <p>Seleccione una recaudadora y mercado, luego presione "Buscar Locales"</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';
import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faStoreAlt, faSearch, faList, faSave, faTimes, faQuestionCircle,
  faEraser, faInbox, faCreditCard, faFileInvoiceDollar, faHandPointer,
  faFilter, faChevronUp, faChevronDown, faAngleLeft, faAngleRight,
  faAngleDoubleLeft, faAngleDoubleRight, faExclamationCircle, faCheckCircle
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

library.add(
  faStoreAlt, faSearch, faList, faSave, faTimes, faQuestionCircle,
  faEraser, faInbox, faCreditCard, faFileInvoiceDollar, faHandPointer,
  faFilter, faChevronUp, faChevronDown, faAngleLeft, faAngleRight,
  faAngleDoubleLeft, faAngleDoubleRight, faExclamationCircle, faCheckCircle
);

const { showLoading, hideLoading } = useGlobalLoading();

// Helper para mostrar toasts
const showToast = (title, icon) => {
  Swal.fire({
    toast: true,
    position: 'top-end',
    icon,
    title,
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true
  });
};

// Estados
const loading = ref(false);
const showFiltros = ref(true);
const recaudadoras = ref([]);
const mercados = ref([]);
const secciones = ref([]);
const categorias = ref([]);
const cajas = ref([]);
const locales = ref([]);
const localSeleccionado = ref(null);
const adeudos = ref([]);

// Paginación de locales
const currentPageLocales = ref(1);
const itemsPerPageLocales = ref(10);

// Filtros
const filtros = ref({
  oficina: '',
  mercado: '',
  categoria: '',
  seccion: '',
  local: ''
});

// Formulario de pago
const formPago = ref({
  fecha_pago: new Date().toISOString().split('T')[0],
  oficina_pago: '',
  caja_pago: '',
  operacion_pago: ''
});

// Computed
const puedesBuscarLocales = computed(() => {
  return filtros.value.oficina && filtros.value.mercado;
});

const hayPagosValidos = computed(() => {
  if (!adeudos.value || adeudos.value.length === 0) return false;
  const validos = adeudos.value.filter(a => a.partida && a.partida.trim() !== '' && a.partida !== '0');
  return validos.length > 0 &&
    formPago.value.fecha_pago &&
    formPago.value.oficina_pago &&
    formPago.value.caja_pago &&
    formPago.value.operacion_pago;
});

const totalAdeudos = computed(() => {
  return adeudos.value.reduce((sum, a) => sum + (parseFloat(a.importe) || 0), 0);
});

// Paginación locales
const totalPagesLocales = computed(() => {
  return Math.ceil(locales.value.length / itemsPerPageLocales.value);
});

const paginatedLocales = computed(() => {
  const start = (currentPageLocales.value - 1) * itemsPerPageLocales.value;
  const end = start + itemsPerPageLocales.value;
  return locales.value.slice(start, end);
});

const visiblePagesLocales = computed(() => {
  const pages = [];
  const maxVisible = 5;
  let startPage = Math.max(1, currentPageLocales.value - Math.floor(maxVisible / 2));
  let endPage = Math.min(totalPagesLocales.value, startPage + maxVisible - 1);

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1);
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i);
  }

  return pages;
});

// Cargar datos iniciales
onMounted(() => {
  cargarRecaudadoras();
  cargarSecciones();
  cargarCategorias();
});

// Cargar recaudadoras
async function cargarRecaudadoras() {
  showLoading('Cargando recaudadoras', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
    showToast('Error al cargar recaudadoras', 'error');
  } finally {
    hideLoading();
  }
}

// Cargar categorías
async function cargarCategorias() {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_categoria_list',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      categorias.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar categorías:', error);
    showToast('Error al cargar categorías', 'error');
  }
}

// Cargar secciones
async function cargarSecciones() {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_secciones',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      secciones.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar secciones:', error);
    showToast('Error al cargar secciones', 'error');
  }
}

// Cuando cambia la oficina
async function onOficinaChange() {
  filtros.value.mercado = '';
  mercados.value = [];
  locales.value = [];
  localSeleccionado.value = null;
  adeudos.value = [];

  if (!filtros.value.oficina) return;

  showLoading('Cargando mercados', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_oficina', tipo: 'integer', valor: parseInt(filtros.value.oficina) },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: 1 }
        ]
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      mercados.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
    showToast('Error al cargar mercados', 'error');
  } finally {
    hideLoading();
  }
}

// Cuando cambia el mercado
function onMercadoChange() {
  locales.value = [];
  localSeleccionado.value = null;
  adeudos.value = [];
}

// Cuando cambia la oficina de pago
async function onOficinaPagoChange() {
  formPago.value.caja_pago = '';
  cajas.value = [];

  if (!formPago.value.oficina_pago) return;

  showLoading('Cargando cajas', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_cajas',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(formPago.value.oficina_pago) }
        ]
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      cajas.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar cajas:', error);
    showToast('Error al cargar cajas', 'error');
  } finally {
    hideLoading();
  }
}

// Buscar locales
async function buscarLocales() {
  if (!puedesBuscarLocales.value) {
    showToast('Seleccione recaudadora y mercado', 'warning');
    return;
  }

  loading.value = true;
  locales.value = [];
  localSeleccionado.value = null;
  adeudos.value = [];
  currentPageLocales.value = 1;

  showLoading('Buscando locales', 'Por favor espere');
  try {
    const params = [
      { nombre: 'p_oficina', tipo: 'smallint', valor: parseInt(filtros.value.oficina) },
      { nombre: 'p_num_mercado', tipo: 'smallint', valor: parseInt(filtros.value.mercado) },
      { nombre: 'p_categoria', tipo: 'smallint', valor: filtros.value.categoria ? parseInt(filtros.value.categoria) : null },
      { nombre: 'p_seccion', tipo: 'character', valor: filtros.value.seccion || null },
      { nombre: 'p_local', tipo: 'integer', valor: filtros.value.local ? parseInt(filtros.value.local) : null },
      { nombre: 'p_letra_local', tipo: 'varchar', valor: null },
      { nombre: 'p_bloque', tipo: 'varchar', valor: null }
    ];

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_locales_by_mercado',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: params
      }
    });

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      locales.value = response.data.eResponse.data.result;

      if (locales.value.length === 0) {
        showToast('No se encontraron locales con los criterios especificados', 'info');
      } else {
        showToast(`Se encontraron ${locales.value.length} locales`, 'success');
      }
    } else {
      showToast('No se encontraron locales', 'info');
    }
  } catch (error) {
    console.error('Error al buscar locales:', error);
    showToast('Error al buscar locales', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Seleccionar local y cargar sus adeudos
async function seleccionarLocal(local) {
  localSeleccionado.value = local;
  adeudos.value = [];

  loading.value = true;
  showLoading('Cargando adeudos', 'Por favor espere');
  try {
    console.log('Consultando adeudos para local:', {
      oficina: local.oficina,
      num_mercado: local.num_mercado,
      categoria: local.categoria,
      seccion: local.seccion,
      local: local.local,
      tiene_adeudo: local.tiene_adeudo
    });

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_adeudos_local',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_oficina', tipo: 'integer', valor: parseInt(local.oficina) },
          { nombre: 'p_mercado', tipo: 'integer', valor: parseInt(local.num_mercado) },
          { nombre: 'p_categoria', tipo: 'integer', valor: parseInt(local.categoria) },
          { nombre: 'p_seccion', tipo: 'varchar', valor: local.seccion },
          { nombre: 'p_local', tipo: 'integer', valor: parseInt(local.local) }
        ]
      }
    });

    console.log('Respuesta de adeudos:', response.data);

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      adeudos.value = response.data.eResponse.data.result.map(a => ({
        ...a,
        partida: ''
      }));

      console.log('Adeudos encontrados:', adeudos.value.length);

      if (adeudos.value.length === 0) {
        showToast('Este local no tiene adeudos pendientes', 'info');
      } else {
        showToast(`Se encontraron ${adeudos.value.length} adeudos`, 'success');
        // Scroll hacia la sección de adeudos
        setTimeout(() => {
          const adeudosSection = document.querySelector('.municipal-card:has(.alert-info)');
          if (adeudosSection) {
            adeudosSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }
        }, 100);
      }
    } else {
      console.warn('No se encontraron adeudos en la respuesta');
      showToast('No se encontraron adeudos', 'info');
      adeudos.value = [];
    }
  } catch (error) {
    console.error('Error al cargar adeudos:', error);
    showToast('Error al cargar adeudos', 'error');
    adeudos.value = [];
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Grabar pagos
async function grabarPagos() {
  const pagosValidos = adeudos.value.filter(a =>
    a.partida && a.partida.trim() !== '' && a.partida !== '0'
  );

  if (pagosValidos.length === 0) {
    showToast('Debe capturar al menos una partida', 'warning');
    return;
  }

  if (!formPago.value.fecha_pago || !formPago.value.oficina_pago ||
    !formPago.value.caja_pago || !formPago.value.operacion_pago) {
    showToast('Complete todos los datos del pago', 'warning');
    return;
  }

  const result = await Swal.fire({
    title: '¿Grabar pagos?',
    html: `
      <p>Se grabarán <strong>${pagosValidos.length}</strong> pagos</p>
      <p>Total: <strong>${formatCurrency(pagosValidos.reduce((sum, a) => sum + parseFloat(a.importe), 0))}</strong></p>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, grabar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#6c2e91'
  });

  if (!result.isConfirmed) return;

  loading.value = true;
  showLoading('Grabando pagos', 'Por favor espere');
  try {
    const pagosJson = pagosValidos.map(a => ({
      id_local: a.id_local,
      axo: a.axo,
      periodo: a.periodo,
      importe: a.importe,
      partida: a.partida
    }));

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_insert_pagos_mercado',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { Nombre: 'p_fecha_pago', Valor: formPago.value.fecha_pago },
          { Nombre: 'p_oficina', Valor: parseInt(formPago.value.oficina_pago) },
          { Nombre: 'p_caja', Valor: formPago.value.caja_pago },
          { Nombre: 'p_operacion', Valor: parseInt(formPago.value.operacion_pago) },
          { Nombre: 'p_usuario', Valor: 1 },
          { Nombre: 'p_mercado', Valor: parseInt(localSeleccionado.value.num_mercado) },
          { Nombre: 'p_categoria', Valor: parseInt(localSeleccionado.value.categoria) },
          { Nombre: 'p_seccion', Valor: localSeleccionado.value.seccion },
          { Nombre: 'p_pagos', Valor: JSON.stringify(pagosJson) }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      await Swal.fire({
        title: '¡Éxito!',
        text: `${pagosValidos.length} pagos grabados correctamente`,
        icon: 'success',
        confirmButtonColor: '#6c2e91'
      });

      // Recargar adeudos del local
      await seleccionarLocal(localSeleccionado.value);

      // Limpiar form de pago
      formPago.value = {
        fecha_pago: new Date().toISOString().split('T')[0],
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: ''
      };
    }
  } catch (error) {
    console.error('Error al grabar pagos:', error);
    showToast('Error al grabar pagos', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

// Cancelar selección
function cancelarSeleccion() {
  localSeleccionado.value = null;
  adeudos.value = [];
  formPago.value = {
    fecha_pago: new Date().toISOString().split('T')[0],
    oficina_pago: '',
    caja_pago: '',
    operacion_pago: ''
  };
}

// Limpiar filtros
function limpiarFiltros() {
  filtros.value = {
    oficina: '',
    mercado: '',
    categoria: '',
    seccion: '',
    local: ''
  };
  locales.value = [];
  mercados.value = [];
  localSeleccionado.value = null;
  adeudos.value = [];
  currentPageLocales.value = 1;
}

// Toggle filtros
function toggleFiltros() {
  showFiltros.value = !showFiltros.value;
}

// Paginación locales
function goToPageLocales(page) {
  if (page >= 1 && page <= totalPagesLocales.value) {
    currentPageLocales.value = page;
  }
}

function changePageSizeLocales(newSize) {
  itemsPerPageLocales.value = parseInt(newSize);
  currentPageLocales.value = 1;
}

// Formato de moneda
function formatCurrency(value) {
  if (!value && value !== 0) return '$0.00';
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value);
}

// Obtener nombre del mes
function getNombreMes(mes) {
  const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  return meses[parseInt(mes) - 1] || mes;
}

// Mostrar ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Carga de Pagos por Locales',
    html: `
      <div style="text-align: left;">
        <h6>Instrucciones:</h6>
        <ol>
          <li><strong>Buscar Locales:</strong> Seleccione recaudadora y mercado. Opcionalmente puede filtrar por categoría, sección o número de local.</li>
          <li><strong>Seleccionar Local:</strong> En la tabla de resultados, presione "Seleccionar" en el local deseado.</li>
          <li><strong>Capturar Partidas:</strong> Se mostrarán los adeudos del local. Capture el número de partida para cada adeudo a pagar.</li>
          <li><strong>Datos del Pago:</strong> Complete la fecha, oficina de pago, caja y número de operación.</li>
          <li><strong>Grabar:</strong> Presione "Grabar Pagos" para registrar los pagos.</li>
        </ol>
        <p><strong>Nota:</strong> Solo se grabarán los adeudos que tengan número de partida capturado.</p>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido',
    confirmButtonColor: '#6c2e91',
    width: 700
  });
}
</script>

<style scoped>
.table-active {
  background-color: rgba(108, 46, 145, 0.1);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.badge-purple {
  background-color: var(--color-municipal-purple);
  color: white;
  padding: 0.35rem 0.75rem;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 600;
}

.alert-info {
  background-color: #e7f3ff;
  border-color: #b3d9ff;
  color: #004085;
}
</style>
