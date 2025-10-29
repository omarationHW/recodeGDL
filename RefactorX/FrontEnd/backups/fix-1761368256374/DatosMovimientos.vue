<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Consulta de Movimientos</h1>
        <p>Mercados - Consulta de Movimientos</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="card mb-3">
      <div class="card-header bg-primary text-white">Movimientos del Local</div>
      <div class="municipal-card-body">
        <div class="row mb-2">
          <div class="col-md-4">
            <label for="id_local">ID Local</label>
            <input v-model="id_local" type="number" class="municipal-form-control" id="id_local" placeholder="Ingrese el ID del local" />
          </div>
          <div class="col-md-2 align-self-end">
            <button class="btn-municipal-success" @click="fetchMovimientos">Buscar</button>
          </div>
        </div>
        <div v-if="movimientos.length > 0">
          <table class="table table-bordered table-sm">
            <thead class="thead-light">
              <tr>
                <th>Control</th>
                <th>Año</th>
                <th>Número</th>
                <th>Actualización</th>
                <th>Nombre</th>
                <th>Sector</th>
                <th>Zona</th>
                <th>Descripción</th>
                <th>Superficie</th>
                <th>Giro</th>
                <th>Fec. Alta</th>
                <th>Fec. Baja</th>
                <th>Vigencia</th>
                <th>Usuario</th>
                <th>Clave Cuota</th>
                <th>Renta</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="mov in movimientos" :key="mov.id_local + '-' + mov.numero_memo">
                <td>{{ mov.id_local }}</td>
                <td>{{ mov.axo_memo }}</td>
                <td>{{ mov.numero_memo }}</td>
                <td>{{ mov.fecha }}</td>
                <td>{{ mov.nombre }}</td>
                <td>{{ mov.sector }}</td>
                <td>{{ mov.zona }}</td>
                <td>{{ mov.drescripcion_local }}</td>
                <td>{{ mov.superficie }}</td>
                <td>{{ mov.giro }}</td>
                <td>{{ mov.fecha_alta }}</td>
                <td>{{ mov.fecha_baja }}</td>
                <td>{{ mov.vigdescripcion }}</td>
                <td>{{ mov.usuario }}</td>
                <td>{{ mov.clave_cuota }}</td>
                <td>{{ mov.renta }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="searched">
          <div class="alert alert-warning">No se encontraron movimientos para el local indicado.</div>
        </div>
      </div>
    </div>
    <div class="card mb-3">
      <div class="municipal-card-header">Catálogo de Claves de Movimiento</div>
      <div class="municipal-card-body">
        <ul>
          <li v-for="c in clavesMov" :key="c.clave_movimiento">{{ c.clave_movimiento }} - {{ c.descripcion }}</li>
        </ul>
      </div>
    </div>
    <div class="card mb-3">
      <div class="municipal-card-header">Catálogo de Claves de Cuota</div>
      <div class="municipal-card-body">
        <ul>
          <li v-for="c in cveCuotas" :key="c.clave_cuota">{{ c.clave_cuota }} - {{ c.descripcion }}</li>
        </ul>
      </div>
    </div>
    <button class="btn-municipal-secondary" @click="$router.back()">Regresar</button>
  </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DatosMovimientosPage',
  data() {
    return {
      id_local: '',
      movimientos: [],
      clavesMov: [],
      cveCuotas: [],
      searched: false
    };
  },
  methods: {
    async fetchMovimientos() {
      if (!this.id_local) return;
      this.searched = false;
      // 1. Movimientos
      const movResp = await this.$axios.post('/api/execute', {
        action: 'get_movimientos_by_local',
        params: { id_local: this.id_local }
      });
      let movs = movResp.data.data || [];
      // 2. Calcular vigdescripcion y renta para cada movimiento
      for (let mov of movs) {
        // Vigencia descripción
        const vigResp = await this.$axios.post('/api/execute', {
          action: 'calc_vigencia_descripcion',
          params: { vigencia: mov.vigencia }
        });
        mov.vigdescripcion = vigResp.data.data;
        // Obtener cuota
        const cuotaResp = await this.$axios.post('/api/execute', {
          action: 'get_cuota_by_params',
          params: {
            vaxo: mov.axo_memo,
            vcat: mov.categoria,
            vsec: mov.seccion,
            vcuo: mov.clave_cuota
          }
        });
        let cuota = cuotaResp.data.data && cuotaResp.data.data[0];
        // Calcular renta
        if (cuota) {
          const rentaResp = await this.$axios.post('/api/execute', {
            action: 'calc_renta',
            params: {
              superficie: mov.superficie,
              importe_cuota: cuota.importe_cuota,
              seccion: mov.seccion,
              clave_cuota: mov.clave_cuota
            }
          });
          mov.renta = rentaResp.data.data;
        } else {
          mov.renta = null;
        }
      }
      this.movimientos = movs;
      this.searched = true;
    },
    async fetchCatalogs() {
      // Claves de movimiento
      const claveMovResp = await this.$axios.post('/api/execute', {
        action: 'get_clave_movimientos'
      });
      this.clavesMov = claveMovResp.data.data || [];
      // Claves de cuota
      const cveCuotaResp = await this.$axios.post('/api/execute', {
        action: 'get_cve_cuotas'
      });
      this.cveCuotas = cveCuotaResp.data.data || [];
    }
  },
  mounted() {
    this.fetchCatalogs();
  }
};
</script>

<style scoped>
.datos-movimientos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  margin-bottom: 1.5rem;
}
</style>
