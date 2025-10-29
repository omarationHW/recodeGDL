<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="users" /></div>
      <div class="module-view-info">
        <h1>Padrón Global de Locales</h1>
        <p>Mercados - Padrón Global de Locales</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="card mb-3">
      <div class="municipal-card-header">Filtros de Consulta</div>
      <div class="card-body row">
        <div class="col-md-3">
          <label for="axo">Año</label>
          <input type="number" v-model="filters.axo" class="municipal-form-control" min="1995" max="3000" />
        </div>
        <div class="col-md-3">
          <label for="mes">Mes</label>
          <input type="number" v-model="filters.mes" class="municipal-form-control" min="1" max="12" />
        </div>
        <div class="col-md-4">
          <label for="vig">Estado del local</label>
          <select v-model="filters.vig" class="municipal-form-control">
            <option value="A">VIGENTES</option>
            <option value="B">CON BAJA TOTAL</option>
            <option value="C">CON BAJA POR ACUERDO</option>
            <option value="D">CON BAJA ADMINISTRATIVA</option>
          </select>
        </div>
        <div class="col-md-2 d-flex align-items-end">
          <button class="btn btn-primary w-100" @click="fetchPadron">Consultar</button>
        </div>
      </div>
    </div>
    <div class="card mb-3">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span>Padrón Global de Locales</span>
        <div>
          <button class="btn btn-success mr-2" @click="exportExcel"><i class="fa fa-file-excel"></i> Exportar Excel</button>
          <button class="btn-municipal-secondary" @click="$router.push('/')"><i class="fa fa-arrow-left"></i> Salir</button>
        </div>
      </div>
      <div class="card-body p-0">
        <div v-if="loading" class="text-center p-4">
          <span class="spinner-border"></span> Cargando datos...
        </div>
        <table v-else class="table table-sm table-striped table-hover mb-0">
          <thead>
            <tr>
              <th>Rec.</th>
              <th>Merc.</th>
              <th>Nombre Mercado</th>
              <th>Cat.</th>
              <th>Secc.</th>
              <th>Local</th>
              <th>Let</th>
              <th>Blq</th>
              <th>Nombre</th>
              <th>Adicionales</th>
              <th>Superficie</th>
              <th>Renta</th>
              <th>Estado</th>
              <th>Leyenda</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in padron" :key="row.id_local">
              <td>{{ row.oficina }}</td>
              <td>{{ row.num_mercado }}</td>
              <td>{{ row.descripcion }}</td>
              <td>{{ row.categoria }}</td>
              <td>{{ row.seccion }}</td>
              <td>{{ row.local }}</td>
              <td>{{ row.letra_local }}</td>
              <td>{{ row.bloque }}</td>
              <td>{{ row.nombre }}</td>
              <td>{{ row.descripcion_local }}</td>
              <td>{{ row.superficie }}</td>
              <td>{{ row.renta | currency }}</td>
              <td>{{ estadoLabel(row.vigencia) }}</td>
              <td>{{ row.leyenda }}</td>
            </tr>
            <tr v-if="padron.length === 0">
              <td colspan="14" class="text-center">No hay datos para los filtros seleccionados.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'PadronGlobalPage',
  data() {
    const now = new Date();
    return {
      filters: {
        axo: now.getFullYear(),
        mes: now.getMonth() + 1,
        vig: 'A'
      },
      padron: [],
      loading: false
    };
  },
  methods: {
    fetchPadron() {
      this.loading = true;
      this.$axios.post('/api/execute', {
        action: 'getPadronGlobal',
        params: this.filters
      }).then(res => {
        this.padron = res.data.data || [];
      }).catch(err => {
        this.$toast.error('Error al consultar el padrón global');
      }).finally(() => {
        this.loading = false;
      });
    },
    exportExcel() {
      this.$axios.post('/api/execute', {
        action: 'exportPadronGlobalExcel',
        params: this.filters
      }).then(res => {
        if (res.data.data && res.data.data.url) {
          window.open(res.data.data.url, '_blank');
        } else {
          this.$toast.error('No se pudo generar el archivo Excel');
        }
      });
    },
    estadoLabel(vig) {
      switch (vig) {
        case 'A': return 'VIGENTE';
        case 'B': return 'BAJA TOTAL';
        case 'C': return 'BAJA POR ACUERDO';
        case 'D': return 'BAJA ADMINISTRATIVA';
        default: return vig;
      }
    }
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
      return val;
    }
  },
  mounted() {
    this.fetchPadron();
  }
};
</script>

<style scoped>
.padron-global-page {
  max-width: 1200px;
  margin: 0 auto;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
