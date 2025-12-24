<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Datos de Energía</h1>
        <p>Inicio > Mercados > Consulta Datos de Energía</p>
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
        
        <button class="btn-municipal-primary" @click="exportar" :disabled="!energia">
          <font-awesome-icon icon="file-excel" />
          Exportar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID Local <span class="required">*</span></label>
              <input
                v-model.number="id_local"
                type="number"
                class="municipal-form-control"
                @keyup.enter="buscar"
                placeholder="Ingrese el ID del local"
              />
            </div>
          </div>
          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscar" :disabled="!id_local">
                <font-awesome-icon icon="search" />
                Buscar
              </button>
              <button class="btn-municipal-secondary" @click="limpiar">
                <font-awesome-icon icon="eraser" />
                Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos de energía -->
      <div v-if="energia">
        <!-- Información general -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="info-circle" />
              Información de Energía
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="row">
              <div class="col-md-6">
                <table class="table table-sm table-bordered">
                  <tbody>
                    <tr><th width="40%">Control Local</th><td><strong class="text-primary">{{ energia.id_local }}</strong></td></tr>
                    <tr>
                      <th>Clave Consumo</th>
                      <td>
                        {{ energia.cve_consumo }}
                        <small class="text-muted">({{ consumoDescripcion }})</small>
                      </td>
                    </tr>
                    <tr><th>Adicionales</th><td>{{ energia.local_adicional || '-' }}</td></tr>
                    <tr><th>Cantidad</th><td>{{ energia.cantidad }}</td></tr>
                    <tr>
                      <th>Vigencia</th>
                      <td>
                        <span :class="energia.vigencia === 'A' ? 'badge bg-success' : 'badge bg-secondary'">
                          {{ vigenciaDescripcion }}
                        </span>
                      </td>
                    </tr>
                    <tr><th>Fecha Alta</th><td>{{ formatDate(energia.fecha_alta) }}</td></tr>
                    <tr><th>Fecha Baja</th><td>{{ formatDate(energia.fecha_baja) || '-' }}</td></tr>
                    <tr><th>Actualización</th><td>{{ formatDate(energia.fecha_modificacion) }}</td></tr>
                    <tr><th>Usuario</th><td>{{ energia.usuario || '-' }}</td></tr>
                  </tbody>
                </table>
              </div>
              <div class="col-md-6">
                <h6 class="mb-3">
                  <font-awesome-icon icon="exclamation-triangle" class="text-warning" />
                  Adeudos por Mes
                </h6>
                <div class="table-responsive" style="max-height: 250px; overflow-y: auto;">
                  <table class="municipal-table">
                    <thead class="municipal-table-header sticky-top">
                      <tr>
                        <th>Año</th>
                        <th>Mes</th>
                        <th class="text-end">Adeudo</th>
                        <th class="text-end">Recargos</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="!adeudos.length">
                        <td colspan="4" class="text-center text-muted">
                          <font-awesome-icon icon="check-circle" class="text-success" />
                          Sin adeudos
                        </td>
                      </tr>
                      <tr v-for="ad in adeudos" :key="`${ad.axo}-${ad.periodo}`" class="row-hover">
                        <td>{{ ad.axo }}</td>
                        <td>{{ ad.periodo }}</td>
                        <td class="text-end"><strong class="text-danger">{{ formatCurrency(ad.importe) }}</strong></td>
                        <td class="text-end">{{ formatCurrency(ad.recargos) }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <!-- Resumen -->
            <div class="row mt-4 mb-3">
              <div class="col-md-4">
                <div class="alert alert-warning mb-0">
                  <strong>Adeudo:</strong> {{ formatCurrency(resumen.adeudos) }}
                </div>
              </div>
              <div class="col-md-4">
                <div class="alert alert-info mb-0">
                  <strong>Recargos:</strong> {{ formatCurrency(resumen.recargos) }}
                </div>
              </div>
              <div class="col-md-4">
                <div class="alert alert-danger mb-0">
                  <strong>Total:</strong> {{ formatCurrency(resumen.total) }}
                </div>
              </div>
            </div>

            <!-- Botones -->
            <div class="text-center">
              <button class="btn-municipal-primary me-2" @click="verPagos">
                <font-awesome-icon icon="dollar-sign" />
                Ver Pagos
              </button>
              <button class="btn-municipal-secondary" @click="verCondonaciones">
                <font-awesome-icon icon="eraser" />
                Ver Condonaciones
              </button>
            </div>
          </div>
        </div>

        <!-- Pagos -->
        <div v-if="pagos.length" class="municipal-card">
          <div class="municipal-card-header header-with-badge">
            <h5>
              <font-awesome-icon icon="dollar-sign" />
              Pagos de Energía
            </h5>
            <div class="header-right">
              <span class="badge-purple">{{ pagos.length }} registros</span>
            </div>
          </div>
          <div class="municipal-card-body table-container">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Año</th>
                    <th>Mes</th>
                    <th>Fecha Pago</th>
                    <th class="text-end">Importe</th>
                    <th>Usuario</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="p in paginatedPagos" :key="p.id_pago_energia" class="row-hover">
                    <td>{{ p.axo }}</td>
                    <td>{{ p.periodo }}</td>
                    <td>{{ formatDate(p.fecha_pago) }}</td>
                    <td class="text-end"><strong class="text-success">{{ formatCurrency(p.importe_pago) }}</strong></td>
                    <td>{{ p.usuario }}</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Paginación Pagos -->
            <div v-if="pagos.length > 10" class="pagination-container">
              <div class="pagination-info">
                Mostrando {{ paginationPagosStart }} a {{ paginationPagosEnd }} de {{ pagos.length }} registros
              </div>
              <div class="pagination-controls">
                <label class="me-2">Registros por página:</label>
                <select v-model.number="itemsPerPagePagos" class="form-select form-select-sm">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                </select>
              </div>
              <div class="pagination-buttons">
                <button @click="prevPagePagos" :disabled="currentPagePagos === 1">
                  <font-awesome-icon icon="chevron-left" />
                </button>
                <span>Página {{ currentPagePagos }} de {{ totalPagesPagos }}</span>
                <button @click="nextPagePagos" :disabled="currentPagePagos === totalPagesPagos">
                  <font-awesome-icon icon="chevron-right" />
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Condonaciones -->
        <div v-if="condonaciones.length" class="municipal-card">
          <div class="municipal-card-header header-with-badge">
            <h5>
              <font-awesome-icon icon="eraser" />
              Condonaciones de Energía
            </h5>
            <div class="header-right">
              <span class="badge-purple">{{ condonaciones.length }} registros</span>
            </div>
          </div>
          <div class="municipal-card-body table-container">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Año</th>
                    <th>Mes</th>
                    <th class="text-end">Importe</th>
                    <th>Observación</th>
                    <th>Usuario</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="c in paginatedCondonaciones" :key="c.id_cancelacion" class="row-hover">
                    <td>{{ c.axo }}</td>
                    <td>{{ c.periodo }}</td>
                    <td class="text-end"><strong class="text-info">{{ formatCurrency(c.importe) }}</strong></td>
                    <td>{{ c.observacion }}</td>
                    <td>{{ c.usuario }}</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Paginación Condonaciones -->
            <div v-if="condonaciones.length > 10" class="pagination-container">
              <div class="pagination-info">
                Mostrando {{ paginationCondonacionesStart }} a {{ paginationCondonacionesEnd }} de {{ condonaciones.length }} registros
              </div>
              <div class="pagination-controls">
                <label class="me-2">Registros por página:</label>
                <select v-model.number="itemsPerPageCondonaciones" class="form-select form-select-sm">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                </select>
              </div>
              <div class="pagination-buttons">
                <button @click="prevPageCondonaciones" :disabled="currentPageCondonaciones === 1">
                  <font-awesome-icon icon="chevron-left" />
                </button>
                <span>Página {{ currentPageCondonaciones }} de {{ totalPagesCondonaciones }}</span>
                <button @click="nextPageCondonaciones" :disabled="currentPageCondonaciones === totalPagesCondonaciones">
                  <font-awesome-icon icon="chevron-right" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-else-if="searchPerformed" class="text-center text-muted py-5">
        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
        <p>No se encontró información de energía para este local</p>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'ConsultaDatosEnergia'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - ConsultaDatosEnergia'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'ConsultaDatosEnergia'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - ConsultaDatosEnergia'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, watch } from 'vue';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const globalLoading = useGlobalLoading();
const { showToast } = useToast();
const id_local = ref('');
const energia = ref(null);
const adeudos = ref([]);
const pagos = ref([]);
const condonaciones = ref([]);
const searchPerformed = ref(false);

// Paginación Pagos
const currentPagePagos = ref(1);
const itemsPerPagePagos = ref(10);

// Paginación Condonaciones
const currentPageCondonaciones = ref(1);
const itemsPerPageCondonaciones = ref(10);

const resumen = computed(() => {
  let total_adeudos = 0, total_recargos = 0;
  adeudos.value.forEach(ad => {
    total_adeudos += Number(ad.importe) || 0;
    total_recargos += Number(ad.recargos) || 0;
  });
  return {
    adeudos: total_adeudos,
    recargos: total_recargos,
    total: total_adeudos + total_recargos
  };
});

const consumoDescripcion = computed(() => {
  if (!energia.value) return '';
  return energia.value.cve_consumo === 'F' ? 'Precio Fijo' :
         energia.value.cve_consumo === 'K' ? 'Kilowatts' : '';
});

const vigenciaDescripcion = computed(() => {
  if (!energia.value) return '';
  if (energia.value.vigencia === 'A') return 'VIGENTE';
  if (energia.value.vigencia === 'E') return 'PARA EMISIÓN';
  if (energia.value.vigencia === 'B') return 'BAJA';
  return energia.value.vigencia;
});

// Paginación Pagos - Computed
const paginatedPagos = computed(() => {
  const start = (currentPagePagos.value - 1) * itemsPerPagePagos.value;
  const end = start + itemsPerPagePagos.value;
  return pagos.value.slice(start, end);
});

const totalPagesPagos = computed(() => {
  return Math.ceil(pagos.value.length / itemsPerPagePagos.value);
});

const paginationPagosStart = computed(() => {
  return pagos.value.length === 0 ? 0 : (currentPagePagos.value - 1) * itemsPerPagePagos.value + 1;
});

const paginationPagosEnd = computed(() => {
  const end = currentPagePagos.value * itemsPerPagePagos.value;
  return end > pagos.value.length ? pagos.value.length : end;
});

// Paginación Condonaciones - Computed
const paginatedCondonaciones = computed(() => {
  const start = (currentPageCondonaciones.value - 1) * itemsPerPageCondonaciones.value;
  const end = start + itemsPerPageCondonaciones.value;
  return condonaciones.value.slice(start, end);
});

const totalPagesCondonaciones = computed(() => {
  return Math.ceil(condonaciones.value.length / itemsPerPageCondonaciones.value);
});

const paginationCondonacionesStart = computed(() => {
  return condonaciones.value.length === 0 ? 0 : (currentPageCondonaciones.value - 1) * itemsPerPageCondonaciones.value + 1;
});

const paginationCondonacionesEnd = computed(() => {
  const end = currentPageCondonaciones.value * itemsPerPageCondonaciones.value;
  return end > condonaciones.value.length ? condonaciones.value.length : end;
});

// Métodos de paginación
const nextPagePagos = () => {
  if (currentPagePagos.value < totalPagesPagos.value) currentPagePagos.value++;
};

const prevPagePagos = () => {
  if (currentPagePagos.value > 1) currentPagePagos.value--;
};

const nextPageCondonaciones = () => {
  if (currentPageCondonaciones.value < totalPagesCondonaciones.value) currentPageCondonaciones.value++;
};

const prevPageCondonaciones = () => {
  if (currentPageCondonaciones.value > 1) currentPageCondonaciones.value--;
};

watch(pagos, () => { currentPagePagos.value = 1; });
watch(condonaciones, () => { currentPageCondonaciones.value = 1; });

const mostrarAyuda = () => {
  showToast('Ingrese el ID del local para consultar sus datos de energía, adeudos, pagos y condonaciones', 'info');
};

const formatCurrency = (value) => {
  if (!value) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const formatDate = (value) => {
  if (!value) return '';
  return new Date(value).toLocaleDateString('es-MX');
};

const buscar = async () => {
  if (!id_local.value) {
    showToast('Ingrese el ID del local', 'warning');
    return;
  }

  searchPerformed.value = true;
  energia.value = null;
  adeudos.value = [];
  pagos.value = [];
  condonaciones.value = [];

  await globalLoading.withLoading(async () => {
    try {
      // Obtener datos de energía
      const resEnergia = await apiService.execute(
          'sp_consulta_energia_get_by_local',
          'mercados',
          [
            { nombre: 'p_id_local', valor: parseInt(id_local.value) }
          ],
          '',
          null,
          'publico'
        );

      if (resEnergia.success) {
        const result = resEnergia.data.result || [];
        if (result.length > 0) {
          energia.value = result[0];

          // Obtener adeudos
          const resAdeudos = await apiService.execute(
          'sp_consulta_energia_get_adeudos',
          'mercados',
          [
                { nombre: 'p_id_local', valor: parseInt(id_local.value) }
              ],
          '',
          null,
          'publico'
        );
          if (resAdeudos.success) {
            adeudos.value = resAdeudos.data.result || [];
          }

          showToast('Datos de energía cargados correctamente', 'success');
        } else {
          showToast('No se encontró información de energía para este local', 'info');
        }
      } else {
        showToast('Error al cargar datos de energía', 'error');
      }
    } catch (e) {
      showToast('Error de comunicación con el servidor', 'error');
      console.error(e);
    }
  }, 'Cargando datos de energía...', 'Por favor espere');
};

const verPagos = async () => {
  if (!energia.value) return;

  await globalLoading.withLoading(async () => {
    try {
      const response = await apiService.execute(
          'sp_consulta_energia_get_pagos',
          'mercados',
          [
            { nombre: 'p_id_energia', valor: energia.value.id_energia }
          ],
          '',
          null,
          'publico'
        );
      if (response?.success) {
        pagos.value = response.data.result || [];
        if (pagos.value.length > 0) {
          showToast(`Se encontraron ${pagos.value.length} pagos`, 'success');
        } else {
          showToast('No hay pagos registrados', 'info');
        }
      }
    } catch (e) {
      showToast('Error al cargar pagos', 'error');
      console.error('Error al cargar pagos:', e);
    }
  }, 'Cargando pagos...', 'Consultando información');
};

const verCondonaciones = async () => {
  if (!energia.value) return;

  await globalLoading.withLoading(async () => {
    try {
      const response = await apiService.execute(
          'sp_consulta_energia_get_condonaciones',
          'mercados',
          [
            { nombre: 'p_id_energia', valor: energia.value.id_energia }
          ],
          '',
          null,
          'publico'
        );
      if (response?.success) {
        condonaciones.value = response.data.result || [];
        if (condonaciones.value.length > 0) {
          showToast(`Se encontraron ${condonaciones.value.length} condonaciones`, 'success');
        } else {
          showToast('No hay condonaciones registradas', 'info');
        }
      }
    } catch (e) {
      showToast('Error al cargar condonaciones', 'error');
      console.error('Error al cargar condonaciones:', e);
    }
  }, 'Cargando condonaciones...', 'Consultando información');
};

const limpiar = () => {
  id_local.value = '';
  energia.value = null;
  adeudos.value = [];
  pagos.value = [];
  condonaciones.value = [];
  searchPerformed.value = false;
  showToast('Búsqueda limpiada', 'info');
};

const exportar = () => {
  if (!energia.value) {
    showToast('No hay datos para exportar', 'warning');
    return;
  }
  showToast('Funcionalidad de exportación en desarrollo', 'info');
};
</script>

<!--
  Estilos removidos - Se utilizan clases municipales globales:
  - .empty-icon, .row-hover, .required, .sticky-top están en municipal-global.css
  - Bootstrap utilities: .text-end, .spinner-border
-->
