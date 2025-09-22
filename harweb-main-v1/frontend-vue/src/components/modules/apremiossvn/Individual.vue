<template>
  <div class="individual-form-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Individual de Folio</li>
      </ol>
    </nav>
    <h1>Consulta Individual de Folio de Requerimientos</h1>
    <form @submit.prevent="buscarFolio">
      <div class="form-row align-items-end">
        <div class="form-group col-md-2">
          <label for="folio">Folio</label>
          <input v-model="folio" type="number" class="form-control" id="folio" required />
        </div>
        <div class="form-group col-md-2">
          <label for="aplicacion">Aplicación</label>
          <select v-model="aplicacion" class="form-control" id="aplicacion">
            <option v-for="(mod, idx) in modulos" :key="mod.value" :value="mod.value">{{ mod.label }}</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label for="rec">Rec</label>
          <input v-model="rec" type="number" class="form-control" id="rec" required />
        </div>
        <div class="form-group col-md-2">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="folioData">
      <h3>Datos Generales</h3>
      <table class="table table-bordered table-sm">
        <tbody>
          <tr><th>Folio</th><td>{{ folioData.folio }}</td></tr>
          <tr><th>Aplicación</th><td>{{ getModuloLabel(folioData.modulo) }}</td></tr>
          <tr><th>Rec</th><td>{{ folioData.zona }}</td></tr>
          <tr><th>Datos</th><td>{{ folioData.datos }}</td></tr>
          <tr><th>Diligencia</th><td>{{ folioData.dil_descrip }}</td></tr>
          <tr><th>Fecha Emisión</th><td>{{ folioData.fecha_emision }}</td></tr>
          <tr><th>Fecha Modif</th><td>{{ folioData.fecha_actualiz }}</td></tr>
          <tr><th>Usuario</th><td>{{ folioData.usu_descrip }}</td></tr>
          <tr><th>Vigencia</th><td>{{ folioData.vig_descrip }}</td></tr>
        </tbody>
      </table>
      <h3>Importes</h3>
      <table class="table table-bordered table-sm">
        <tbody>
          <tr><th>Imp. Adeudo</th><td>{{ folioData.importe_global }}</td></tr>
          <tr><th>Imp. Recargo</th><td>{{ folioData.importe_recargo }}</td></tr>
          <tr><th>Imp. Multa</th><td>{{ folioData.importe_multa }}</td></tr>
          <tr><th>Imp. Gastos</th><td>{{ folioData.importe_gastos }}</td></tr>
          <tr><th>Imp. Actualización</th><td>{{ folioData.importe_actualizacion }}</td></tr>
        </tbody>
      </table>
      <h3>Movimientos</h3>
      <table class="table table-bordered table-sm">
        <tbody>
          <tr><th>Clave Practicado</th><td>{{ folioData.pra_descrip }}</td></tr>
          <tr><th>Fecha Practicado</th><td>{{ folioData.fecha_practicado }}</td></tr>
          <tr><th>Hora Practicado</th><td>{{ folioData.hora_practicado }}</td></tr>
          <tr><th>Fecha Citatorio</th><td>{{ folioData.fecha_citatorio }}</td></tr>
          <tr><th>Hora Citatorio</th><td>{{ folioData.hora }}</td></tr>
          <tr><th>Zona</th><td>{{ folioData.zona_apremio }}</td></tr>
          <tr><th>Porcentaje Multa</th><td>{{ folioData.porcentaje_multa }}</td></tr>
        </tbody>
      </table>
      <h3>Ejecutor</h3>
      <table class="table table-bordered table-sm">
        <tbody>
          <tr><th>Ejecutor</th><td>{{ folioData.ejecutor }}</td></tr>
          <tr><th>Nombre</th><td>{{ folioData.nombre_eje }}</td></tr>
          <tr><th>Fecha Entrega 1</th><td>{{ folioData.fecha_entrega1 }}</td></tr>
          <tr><th>Fecha Entrega 2</th><td>{{ folioData.fecha_entrega2 }}</td></tr>
        </tbody>
      </table>
      <h3>Secuestro/Remate</h3>
      <table class="table table-bordered table-sm">
        <tbody>
          <tr><th>Clave Secuestro</th><td>{{ folioData.sec_descrip }}</td></tr>
          <tr><th>Clave Remate</th><td>{{ folioData.rem_descrip }}</td></tr>
          <tr><th>Fecha Remate</th><td>{{ folioData.fecha_remate }}</td></tr>
        </tbody>
      </table>
      <h3>Pagos</h3>
      <table class="table table-bordered table-sm">
        <tbody>
          <tr><th>Fecha Pago</th><td>{{ folioData.fecha_pago }}</td></tr>
          <tr><th>Rec de Pago</th><td>{{ folioData.recaudadora }}</td></tr>
          <tr><th>Caja de Pago</th><td>{{ folioData.caja }}</td></tr>
          <tr><th>Operación</th><td>{{ folioData.operacion }}</td></tr>
          <tr><th>Importe Pago</th><td>{{ folioData.importe_pago }}</td></tr>
        </tbody>
      </table>
      <h3>Observaciones</h3>
      <div class="alert alert-secondary">{{ folioData.observaciones }}</div>
      <h3>Historia</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Movimiento</th>
            <th>Usuario</th>
            <th>Observaciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="h in history" :key="h.fecha_actualiz">
            <td>{{ h.fecha_actualiz }}</td>
            <td>{{ h.clave_mov }}</td>
            <td>{{ h.usuario }}</td>
            <td>{{ h.observaciones }}</td>
          </tr>
        </tbody>
      </table>
      <h3>Periodos</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Año</th>
            <th>Periodo</th>
            <th>Importe</th>
            <th>Recargos</th>
            <th>Cantidad</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in periods" :key="p.ayo + '-' + p.periodo">
            <td>{{ p.ayo }}</td>
            <td>{{ p.periodo }}</td>
            <td>{{ p.importe }}</td>
            <td>{{ p.recargos }}</td>
            <td>{{ p.cantidad }}</td>
          </tr>
        </tbody>
      </table>
      <h3>Detalle de Aplicación</h3>
      <div v-if="moduleDetails">
        <pre>{{ moduleDetails }}</pre>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'IndividualFolioPage',
  data() {
    return {
      folio: '',
      aplicacion: 11,
      rec: '',
      folioData: null,
      history: [],
      periods: [],
      moduleDetails: null,
      loading: false,
      error: '',
      modulos: [
        { value: 11, label: 'Mercados' },
        { value: 16, label: 'Aseo' },
        { value: 24, label: 'Estacionamientos Públicos' },
        { value: 28, label: 'Estacionamientos Exclusivos' },
        { value: 14, label: 'Estacionómetros' },
        { value: 13, label: 'Cementerios' }
      ]
    };
  },
  methods: {
    getModuloLabel(val) {
      const m = this.modulos.find(x => x.value === val);
      return m ? m.label : val;
    },
    async buscarFolio() {
      this.loading = true;
      this.error = '';
      this.folioData = null;
      this.history = [];
      this.periods = [];
      this.moduleDetails = null;
      try {
        // 1. Obtener folio principal
        let resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getFolio',
            params: { folio: this.folio }
          }
        });
        if (!resp.data.eResponse.success || !resp.data.eResponse.data.length) {
          throw new Error('Folio no encontrado');
        }
        this.folioData = resp.data.eResponse.data[0];
        // 2. Historia
        let respHist = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getFolioHistory',
            params: { id_control: this.folioData.id_control }
          }
        });
        this.history = respHist.data.eResponse.data;
        // 3. Periodos
        let respPer = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getFolioPeriods',
            params: { id_control: this.folioData.id_control }
          }
        });
        this.periods = respPer.data.eResponse.data;
        // 4. Detalle de módulo
        let respMod = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getModuleDetails',
            params: {
              modulo: this.folioData.modulo,
              control_otr: this.folioData.control_otr
            }
          }
        });
        this.moduleDetails = respMod.data.eResponse.data[0] || null;
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.individual-form-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
