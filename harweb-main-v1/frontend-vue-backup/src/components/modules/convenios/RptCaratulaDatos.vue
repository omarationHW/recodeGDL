<template>
  <div class="rpt-caratula-datos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Carátula de Contrato</li>
      </ol>
    </nav>
    <h2>Carátula de Contrato</h2>
    <form @submit.prevent="buscarContrato">
      <div class="form-group row">
        <label class="col-sm-2 col-form-label">ID Contrato/Convenio</label>
        <div class="col-sm-4">
          <input v-model="contratoId" type="number" class="form-control" required />
        </div>
        <div class="col-sm-2">
          <button class="btn btn-primary" type="submit">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="my-3">
      <span>Cargando...</span>
    </div>
    <div v-if="error" class="alert alert-danger my-3">{{ error }}</div>
    <div v-if="caratula">
      <div class="card my-4">
        <div class="card-header bg-light">
          <strong>Datos de la Obra</strong>
        </div>
        <div class="card-body">
          <div class="row mb-2">
            <div class="col-md-3"><strong>Colonia:</strong> {{ caratula.descripcion }}</div>
            <div class="col-md-3"><strong>Obra:</strong> {{ caratula.descripcion_1 }}</div>
            <div class="col-md-3"><strong>Fondo:</strong> {{ caratula.descripcion_2 }}</div>
            <div class="col-md-3"><strong>Año de Obra:</strong> {{ caratula.axo_obra }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-3"><strong>Vigencia de Obra:</strong> {{ caratula.estado_obra }}</div>
            <div class="col-md-3"><strong>Plazo:</strong> {{ caratula.plazo }} {{ caratula.desc_plazo }}</div>
          </div>
        </div>
      </div>
      <div class="card my-4">
        <div class="card-header bg-light">
          <strong>Datos del Contrato</strong>
        </div>
        <div class="card-body">
          <div class="row mb-2">
            <div class="col-md-3"><strong>Control:</strong> {{ caratula.id_convenio }}</div>
            <div class="col-md-3"><strong>Contrato:</strong> {{ caratula.contrato }}</div>
            <div class="col-md-3"><strong>Nombre:</strong> {{ caratula.nombre }}</div>
            <div class="col-md-3"><strong>Domicilio:</strong> {{ caratula.desc_calle }} {{ caratula.numero }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-3"><strong>Tipo de Casa:</strong> {{ caratula.tipo_casa }}</div>
            <div class="col-md-3"><strong>Mtrs. Frente:</strong> {{ caratula.mtrs_frente }}</div>
            <div class="col-md-3"><strong>Ancho:</strong> {{ caratula.mtrs_ancho }}</div>
            <div class="col-md-3"><strong>Metros2:</strong> {{ caratula.metros2 }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-6"><strong>Entre Calle:</strong> {{ caratula.entrecalles }}</div>
            <div class="col-md-6"><strong>Fecha Vencimiento:</strong> {{ caratula.fecha_vencimiento }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-3"><strong>Pago Total:</strong> {{ caratula.pago_total }}</div>
            <div class="col-md-3"><strong>Inicial:</strong> {{ caratula.pago_inicial }}</div>
            <div class="col-md-3"><strong>Pagos:</strong> {{ caratula.pagos_parciales }}</div>
            <div class="col-md-3"><strong>Parcial:</strong> {{ caratula.pago_quincenal }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-3"><strong>Saldo Insoluto:</strong> {{ caratula.saldo_insoluto }}</div>
            <div class="col-md-3"><strong>Descuento:</strong> {{ caratula.descuento }}</div>
            <div class="col-md-3"><strong>Recargos Conveniados:</strong> {{ caratula.recargos_conv }}</div>
            <div class="col-md-3"><strong>Imp.Obra Conveniada:</strong> {{ caratula.impobra_conv }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-12"><strong>Observaciones:</strong> {{ caratula.observacion }}</div>
          </div>
        </div>
      </div>
      <div class="card my-4">
        <div class="card-header bg-light">
          <strong>Estado de Cuenta</strong>
        </div>
        <div class="card-body">
          <div class="row mb-2">
            <div class="col-md-3"><strong>Total Pagado:</strong> {{ caratula.pagos }}</div>
            <div class="col-md-3"><strong>Adeudo:</strong> {{ caratula.adeudo }}</div>
            <div class="col-md-3"><strong>Recargos:</strong> {{ caratula.recargos }}</div>
            <div class="col-md-3"><strong>Total Global:</strong> {{ caratula.total }}</div>
          </div>
        </div>
      </div>
      <div class="card my-4">
        <div class="card-header bg-light">
          <strong>Pagos a Detalle</strong>
        </div>
        <div class="card-body">
          <table class="table table-sm table-bordered">
            <thead>
              <tr>
                <th>Parcial</th>
                <th>Fecha de Pago</th>
                <th>Rec.</th>
                <th>Caja</th>
                <th>Oper.</th>
                <th>Importe</th>
                <th>Desc.</th>
                <th>Recargos</th>
                <th>Usuario</th>
                <th>Actualización</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagosDetalle" :key="pago.id_pago">
                <td>{{ pago.parcialidades }}</td>
                <td>{{ pago.fecha_pago }}</td>
                <td>{{ pago.oficina_pago }}</td>
                <td>{{ pago.caja_pago }}</td>
                <td>{{ pago.operacion_pago }}</td>
                <td>{{ pago.importe }}</td>
                <td>{{ pago.cve_descuento }}</td>
                <td>{{ pago.RecarCalc }}</td>
                <td>{{ pago.usuario }}</td>
                <td>{{ pago.fecha_actual }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div v-if="ampliacionPlazo">
        <div class="card my-4">
          <div class="card-header bg-light">
            <strong>Última Ampliación de Plazo</strong>
          </div>
          <div class="card-body">
            <div class="row mb-2">
              <div class="col-md-3"><strong>Año Oficio:</strong> {{ ampliacionPlazo.axo_oficio }}</div>
              <div class="col-md-3"><strong>Folio Oficio:</strong> {{ ampliacionPlazo.folio_oficio }}</div>
              <div class="col-md-3"><strong>Total:</strong> {{ ampliacionPlazo.total }}</div>
              <div class="col-md-3"><strong>Fecha Inicio:</strong> {{ ampliacionPlazo.fecha_inicio }}</div>
              <div class="col-md-3"><strong>Fecha Fin:</strong> {{ ampliacionPlazo.fecha_fin }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptCaratulaDatosPage',
  data() {
    return {
      contratoId: '',
      caratula: null,
      pagosDetalle: [],
      ampliacionPlazo: null,
      loading: false,
      error: ''
    };
  },
  methods: {
    async buscarContrato() {
      this.loading = true;
      this.error = '';
      this.caratula = null;
      this.pagosDetalle = [];
      this.ampliacionPlazo = null;
      try {
        // 1. Datos principales
        let res = await this.$axios.post('/api/execute', {
          action: 'getCaratulaDatos',
          params: { contrato: this.contratoId }
        });
        if (!res.data.success || !res.data.data) {
          this.error = res.data.message || 'No se encontró el contrato';
          this.loading = false;
          return;
        }
        this.caratula = res.data.data;
        // 2. Pagos detalle
        let pagosRes = await this.$axios.post('/api/execute', {
          action: 'getPagosDetalle',
          params: { contrato: this.contratoId }
        });
        this.pagosDetalle = pagosRes.data.data || [];
        // 3. Ampliación de plazo
        let ampRes = await this.$axios.post('/api/execute', {
          action: 'getAmpliacionPlazo',
          params: { contrato: this.contratoId }
        });
        this.ampliacionPlazo = ampRes.data.data;
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.rpt-caratula-datos-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
</style>
