<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="map" /></div>
      <div class="module-view-info"><h1>Reporte Catálogo de Mercados</h1><p>Inicio > Mercados > Catálogo</p></div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="consultar" :disabled="loading"><font-awesome-icon icon="search" /> Consultar</button>
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || results.length === 0"><font-awesome-icon icon="file-excel" /> Exportar</button>
        <button class="btn-municipal-purple" @click="mostrarAyuda"><font-awesome-icon icon="question-circle" /> Ayuda</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header"><h5><font-awesome-icon icon="filter" /> Filtros</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Recaudadora</label><select v-model="filters.oficina" class="municipal-form-control" :disabled="loading"><option value="">Todas</option><option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_recaudadora }} - {{ rec.descripcion }}</option></select></div>
            <div class="form-group"><label class="municipal-form-label">Estado</label><select v-model="filters.estado" class="municipal-form-control" :disabled="loading"><option value="">Todos</option><option value="A">Activo</option><option value="I">Inactivo</option></select></div>
          </div>
        </div>
      </div>
      <div v-if="loading" class="text-center py-5"><div class="spinner-border municipal-text-primary" role="status"><span class="visually-hidden">Cargando...</span></div><p class="mt-2">Cargando catálogo...</p></div>
      <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info"><font-awesome-icon icon="info-circle" /> Haga clic en <strong>Consultar</strong> para ver el catálogo de mercados.</div>
      <div v-if="busquedaRealizada && !results.length && !loading" class="municipal-alert municipal-alert-warning"><font-awesome-icon icon="exclamation-triangle" /> No se encontraron mercados.</div>
      <div v-if="results.length && !loading" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge"><h5><font-awesome-icon icon="list-alt" /> Catálogo de Mercados</h5><div class="header-right"><span class="badge-purple">{{ results.length }} mercados</span></div></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header"><tr><th>Oficina</th><th>Mercado</th><th>Descripción</th><th>Domicilio</th><th>Zona</th><th>Tipo Emisión</th><th>Estado</th></tr></thead><tbody><tr v-for="(row, idx) in paginatedResults" :key="idx" class="row-hover"><td>{{ row.oficina }}</td><td>{{ row.num_mercado_nvo }}</td><td>{{ row.descripcion }}</td><td>{{ row.domicilio }}</td><td>{{ row.zona }}</td><td><span :class="getBadgeTipoEmision(row.tipo_emision)">{{ getTipoEmisionTexto(row.tipo_emision) }}</span></td><td><span :class="getBadgeEstado(row.estado)">{{ getEstadoTexto(row.estado) }}</span></td></tr></tbody></table></div>
          <!-- Controles de Paginación -->
          <div v-if="results.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * pageSize) + 1 }}
                a {{ Math.min(currentPage * pageSize, results.length) }}
                de {{ results.length }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="pageSize"
                @change="changePageSize($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
                <option value="250">250</option>
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
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading();

const filters = ref({ oficina: '', estado: '' });
const recaudadoras = ref([]);
const results = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);
const currentPage = ref(1);
const pageSize = ref(10);

const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);
const paginatedResults = computed(() => { const start = (currentPage.value - 1) * pageSize.value; return results.value.slice(start, start + pageSize.value); });

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

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return;
  currentPage.value = page;
};

const changePageSize = (size) => {
  pageSize.value = parseInt(size);
  currentPage.value = 1;
};

const fetchRecaudadoras = async () => { showLoading('Cargando recaudadoras...', 'Por favor espere'); loading.value = true; try { const response = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_get_recaudadoras', Base: 'mercados', Parametros: [] } }); if (response.data.eResponse?.success && response.data.eResponse?.data?.result) { recaudadoras.value = response.data.eResponse.data.result; } } catch (error) { console.error('Error:', error); } finally { loading.value = false; hideLoading(); } };
const consultar = async () => { showLoading('Consultando catálogo de mercados...', 'Por favor espere'); loading.value = true; busquedaRealizada.value = false; try { const parametros = []; if (filters.value.oficina) parametros.push({ Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) }); if (filters.value.estado) parametros.push({ Nombre: 'p_estado', Valor: filters.value.estado }); const response = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_reporte_catalogo_mercados', Base: 'mercados', Parametros: parametros } }); if (response.data.eResponse?.success && response.data.eResponse?.data?.result) { results.value = response.data.eResponse.data.result; busquedaRealizada.value = true; currentPage.value = 1; } else { results.value = []; busquedaRealizada.value = true; } } catch (error) { console.error('Error:', error); results.value = []; busquedaRealizada.value = true; } finally { loading.value = false; hideLoading(); } };

const getTipoEmisionTexto = (tipo) => { const tipos = { 'D': 'Diario', 'M': 'Mensual', 'E': 'Especial' }; return tipos[tipo] || tipo; };
const getBadgeTipoEmision = (tipo) => { const badges = { 'D': 'badge-info', 'M': 'badge-primary', 'E': 'badge-warning' }; return badges[tipo] || 'badge-secondary'; };
const getEstadoTexto = (estado) => { return estado === 'A' ? 'Activo' : 'Inactivo'; };
const getBadgeEstado = (estado) => { return estado === 'A' ? 'badge-success' : 'badge-danger'; };

const exportarExcel = () => { const data = results.value.map(row => ({ 'Oficina': row.oficina, 'Mercado': row.num_mercado_nvo, 'Descripción': row.descripcion, 'Domicilio': row.domicilio, 'Zona': row.zona, 'Tipo Emisión': getTipoEmisionTexto(row.tipo_emision), 'Estado': getEstadoTexto(row.estado) })); const csv = [Object.keys(data[0]).join(','), ...data.map(row => Object.values(row).join(','))].join('\n'); const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' }); const url = window.URL.createObjectURL(blob); const a = document.createElement('a'); a.href = url; a.download = `catalogo_mercados.csv`; a.click(); window.URL.revokeObjectURL(url); };
const mostrarAyuda = () => { alert('Reporte Catálogo de Mercados\n\nGenera un listado completo del catálogo de mercados registrados.\n\nPuede filtrar por recaudadora y estado (activo/inactivo).'); };

onMounted(() => { fetchRecaudadoras(); });
</script>

