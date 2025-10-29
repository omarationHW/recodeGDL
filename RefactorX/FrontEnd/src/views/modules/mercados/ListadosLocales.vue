<template>
  <div class="module-view">
    <h1>Listados de Mercados</h1>
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="store" /></div>
      <div class="module-view-info">
        <h1>Listados de Mercados</h1>
        <p>Mercados - Listados de Mercados</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">Seleccione el tipo de listado</div>
      <div class="municipal-card-body">
        <div class="form-check form-check-inline">
          <input class="form-check-input" type="radio" id="padron" value="padron" v-model="tipoListado">
          <label class="form-check-label" for="padron">Padrón de Locales</label>
        </div>
        <div class="form-check form-check-inline">
          <input class="form-check-input" type="radio" id="movimientos" value="movimientos" v-model="tipoListado">
          <label class="form-check-label" for="movimientos">Movimientos Locales</label>
        </div>
        <div class="form-check form-check-inline">
          <input class="form-check-input" type="radio" id="pagos" value="pagos" v-model="tipoListado" disabled>
          <label class="form-check-label" for="pagos">Movimientos Pagos</label>
        </div>
        <div class="form-check form-check-inline">
          <input class="form-check-input" type="radio" id="ingresozonas" value="ingresozonas" v-model="tipoListado">
          <label class="form-check-label" for="ingresozonas">Ingreso por Zonas</label>
        </div>
      </div>
    </div>

    <div v-if="tipoListado === 'padron'" class="municipal-card mb-3">
      <div class="municipal-card-header">Padrón de Locales</div>
      <div class="municipal-card-body">
        <div class="row mb-2">
          <div class="col-md-3">
            <label class="municipal-form-label">Recaudadora</label>
            <select v-model="selectedRecaudadora" class="municipal-form-control" @change="fetchMercados">
              <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.recaudadora }}</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Mercado</label>
            <select v-model="selectedMercado" class="municipal-form-control">
              <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.descripcion }}</option>
            </select>
          </div>
          <div class="col-md-3 align-self-end">
            <button class="btn-municipal-primary" @click="buscarPadron">Buscar</button>
            <button class="btn btn-municipal-success ml-2" @click="exportarExcel" :disabled="locales.length === 0">Exportar Excel</button>
          </div>
        </div>
        <div v-if="locales.length > 0">
          <table class="municipal-table">
            <thead>
              <tr>
                <th>Rec.</th>
                <th>Mercado</th>
                <th>Cat.</th>
                <th>Sección</th>
                <th>Local</th>
                <th>Letra</th>
                <th>Bloque</th>
                <th>Nombre</th>
                <th>Superficie</th>
                <th>Renta</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="loc in locales" :key="loc.id_local">
                <td>{{ loc.oficina }}</td>
                <td>{{ loc.num_mercado }}</td>
                <td>{{ loc.categoria }}</td>
                <td>{{ loc.seccion }}</td>
                <td>{{ loc.local }}</td>
                <td>{{ loc.letra_local }}</td>
                <td>{{ loc.bloque }}</td>
                <td>{{ loc.nombre }}</td>
                <td>{{ loc.superficie }}</td>
                <td>{{ loc.renta }}</td>
                <td>{{ loc.vigencia }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="padronBuscado">No hay resultados para el padrón seleccionado.</div>
      </div>
    </div>

    <div v-if="tipoListado === 'movimientos'" class="municipal-card mb-3">
      <div class="municipal-card-header">Movimientos Locales</div>
      <div class="municipal-card-body">
        <div class="row mb-2">
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Desde</label>
            <input type="date" v-model="fechaDesde" class="municipal-form-control" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Hasta</label>
            <input type="date" v-model="fechaHasta" class="municipal-form-control" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Recaudadora</label>
            <select v-model="selectedRecaudadora" class="municipal-form-control">
              <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.recaudadora }}</option>
            </select>
          </div>
          <div class="col-md-3 align-self-end">
            <button class="btn-municipal-primary" @click="buscarMovimientos">Buscar</button>
          </div>
        </div>
        <div v-if="movimientos.length > 0">
          <table class="municipal-table">
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Rec.</th>
                <th>Mercado</th>
                <th>Cat.</th>
                <th>Sección</th>
                <th>Local</th>
                <th>Letra</th>
                <th>Bloque</th>
                <th>Tipo</th>
                <th>Nombre</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="mov in movimientos" :key="mov.id_movimiento">
                <td>{{ mov.fecha }}</td>
                <td>{{ mov.oficina }}</td>
                <td>{{ mov.num_mercado }}</td>
                <td>{{ mov.categoria }}</td>
                <td>{{ mov.seccion }}</td>
                <td>{{ mov.local }}</td>
                <td>{{ mov.letra_local }}</td>
                <td>{{ mov.bloque }}</td>
                <td>{{ mov.tipodescripcion }}</td>
                <td>{{ mov.nombre }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="movimientosBuscados">No hay movimientos para los filtros seleccionados.</div>
      </div>
    </div>

    <div v-if="tipoListado === 'ingresozonas'" class="municipal-card mb-3">
      <div class="municipal-card-header">Ingreso por Zonas</div>
      <div class="municipal-card-body">
        <div class="row mb-2">
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Desde</label>
            <input type="date" v-model="fechaDesde" class="municipal-form-control" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Hasta</label>
            <input type="date" v-model="fechaHasta" class="municipal-form-control" />
          </div>
          <div class="col-md-3 align-self-end">
            <button class="btn-municipal-primary" @click="buscarIngresoZonificado">Buscar</button>
          </div>
        </div>
        <div v-if="ingresos.length > 0">
          <table class="municipal-table">
            <thead>
              <tr>
                <th>Zona</th>
                <th>Importe Pagado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="ing in ingresos" :key="ing.id_zona">
                <td>{{ ing.zona }}</td>
                <td>{{ ing.pagado }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="ingresosBuscados">No hay ingresos para el rango seleccionado.</div>
      </div>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'ListadosLocalesPage',
  data() {
    return {
      tipoListado: 'padron',
      recaudadoras: [],
      mercados: [],
      selectedRecaudadora: '',
      selectedMercado: '',
      locales: [],
      movimientos: [],
      ingresos: [],
      fechaDesde: '',
      fechaHasta: '',
      padronBuscado: false,
      movimientosBuscados: false,
      ingresosBuscados: false
    };
  },
  mounted() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getRecaudadoras' });
      this.recaudadoras = res.data.recaudadoras;
      if (this.recaudadoras.length > 0) {
        this.selectedRecaudadora = this.recaudadoras[0].id_rec;
        this.fetchMercados();
      }
    },
    async fetchMercados() {
      if (!this.selectedRecaudadora) return;
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getMercadosByRecaudadora', params: { recaudadora_id: this.selectedRecaudadora } });
      this.mercados = res.data.mercados;
      if (this.mercados.length > 0) {
        this.selectedMercado = this.mercados[0].num_mercado_nvo;
      }
    },
    async buscarPadron() {
      if (!this.selectedRecaudadora || !this.selectedMercado) return;
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        action: 'getPadronLocales',
        params: {
          recaudadora_id: this.selectedRecaudadora,
          mercado_id: this.selectedMercado
        }
      });
      this.locales = res.data.locales;
      this.padronBuscado = true;
    },
    async buscarMovimientos() {
      if (!this.selectedRecaudadora || !this.fechaDesde || !this.fechaHasta) return;
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        action: 'getMovimientosLocales',
        params: {
          recaudadora_id: this.selectedRecaudadora,
          fecha_desde: this.fechaDesde,
          fecha_hasta: this.fechaHasta
        }
      });
      this.movimientos = res.data.movimientos;
      this.movimientosBuscados = true;
    },
    async buscarIngresoZonificado() {
      if (!this.fechaDesde || !this.fechaHasta) return;
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        action: 'getIngresoZonificado',
        params: {
          fecha_desde: this.fechaDesde,
          fecha_hasta: this.fechaHasta
        }
      });
      this.ingresos = res.data.ingresos;
      this.ingresosBuscados = true;
    },
    async exportarExcel() {
      // Aquí se puede implementar la descarga real
      alert('Exportación a Excel no implementada en este demo.');
    }
  }
};
</script>

<style scoped>
.listados-locales-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  margin-bottom: 1.5rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
