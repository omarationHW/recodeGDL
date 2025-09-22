<template>
  <div class="pagosmultfrm-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de pagos de multas</li>
      </ol>
    </nav>
    <div v-if="!showResults">
      <div class="card mb-4">
        <div class="card-header bg-primary text-white">
          Consulta de pagos de multas
        </div>
        <div class="card-body">
          <form @submit.prevent="buscarPagos">
            <div class="row mb-3">
              <div class="col-md-2">
                <label for="fecha" class="form-label">Fecha</label>
                <input type="date" v-model="form.fecha" class="form-control" id="fecha">
              </div>
              <div class="col-md-1">
                <label for="recaud" class="form-label">Rec</label>
                <input type="text" v-model="form.recaud" class="form-control" id="recaud">
              </div>
              <div class="col-md-1">
                <label for="caja" class="form-label">Caja</label>
                <input type="text" v-model="form.caja" class="form-control" id="caja">
              </div>
              <div class="col-md-2">
                <label for="folio" class="form-label">Folio</label>
                <input type="text" v-model="form.folio" class="form-control" id="folio">
              </div>
              <div class="col-md-3">
                <label for="nombre" class="form-label">Nombre</label>
                <input type="text" v-model="form.nombre" class="form-control" id="nombre">
              </div>
              <div class="col-md-3">
                <label for="num_acta" class="form-label">Num. Acta</label>
                <input type="text" v-model="form.num_acta" class="form-control" id="num_acta">
              </div>
            </div>
            <button type="submit" class="btn btn-success">Buscar</button>
          </form>
        </div>
      </div>
    </div>
    <div v-else>
      <div class="mb-3">
        <button class="btn btn-secondary" @click="resetBusqueda">Otra búsqueda</button>
      </div>
      <div v-if="pagos.length === 0" class="alert alert-warning">
        No existen recibos de multas con este criterio.
      </div>
      <div v-else>
        <div class="table-responsive mb-4">
          <table class="table table-bordered table-hover">
            <thead class="table-light">
              <tr>
                <th>Fecha</th>
                <th>Recaud</th>
                <th>Caja</th>
                <th>Folio</th>
                <th>Hora</th>
                <th>Importe</th>
                <th>Cajero</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagos" :key="pago.cvepago">
                <td>{{ pago.fecha }}</td>
                <td>{{ pago.recaud }}</td>
                <td>{{ pago.caja }}</td>
                <td>{{ pago.folio }}</td>
                <td>{{ pago.hora }}</td>
                <td>{{ pago.importe | currency }}</td>
                <td>{{ pago.cajero }}</td>
                <td>
                  <button class="btn btn-sm btn-info" @click="verDetalle(pago)">Detalle</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-if="detalle">
          <h5>Detalle de Multa</h5>
          <div class="row mb-2">
            <div class="col-md-4"><strong>Contribuyente:</strong> {{ detalle.contribuyente }}</div>
            <div class="col-md-4"><strong>Domicilio:</strong> {{ detalle.domicilio }}</div>
            <div class="col-md-4"><strong>Giro:</strong> {{ detalle.giro }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-3"><strong>Dependencia:</strong> {{ detalle.dependencia }}</div>
            <div class="col-md-3"><strong>Ley:</strong> {{ detalle.ley }}</div>
            <div class="col-md-3"><strong>Infracción:</strong> {{ detalle.infraccion }}</div>
            <div class="col-md-3"><strong>Expediente:</strong> {{ detalle.expediente }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-2"><strong>Lote:</strong> {{ detalle.num_lote }}</div>
            <div class="col-md-2"><strong>Remesa:</strong> {{ detalle.num_remesa }}</div>
            <div class="col-md-2"><strong>Zona:</strong> {{ detalle.zona }}</div>
            <div class="col-md-2"><strong>Subzona:</strong> {{ detalle.subzona }}</div>
            <div class="col-md-2"><strong>Licencia:</strong> {{ detalle.num_licencia }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-2"><strong>Calificación:</strong> {{ detalle.calificacion | currency }}</div>
            <div class="col-md-2"><strong>Descuento:</strong> {{ detalle.descuento | currency }}</div>
            <div class="col-md-2"><strong>Multa:</strong> {{ detalle.multa | currency }}</div>
            <div class="col-md-2"><strong>Gastos:</strong> {{ detalle.gastos | currency }}</div>
            <div class="col-md-2"><strong>Total:</strong> {{ detalle.total | currency }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-3"><strong>Fecha Acta:</strong> {{ detalle.fecha_acta }}</div>
            <div class="col-md-3"><strong>Fecha Recepción:</strong> {{ detalle.fecha_recepcion }}</div>
            <div class="col-md-3"><strong>Fecha Cancelación:</strong> {{ detalle.fecha_cancelacion }}</div>
            <div class="col-md-3"><strong>Estatus:</strong> {{ detalle.estatus }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-12"><strong>Observación:</strong> <pre>{{ detalle.observacion }}</pre></div>
          </div>
          <div class="row mb-2">
            <div class="col-md-12">
              <h6>Descuentos</h6>
              <table class="table table-sm table-bordered">
                <thead>
                  <tr>
                    <th>Tipo</th>
                    <th>Valor</th>
                    <th>Fecha</th>
                    <th>Capturista</th>
                    <th>Autoriza</th>
                    <th>Observación</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="desc in descuentos" :key="desc.id_descuento">
                    <td>{{ desc.tipo_descto }}</td>
                    <td>{{ desc.valor }}</td>
                    <td>{{ desc.feccap }}</td>
                    <td>{{ desc.capturista }}</td>
                    <td>{{ desc.descripcion }}</td>
                    <td>{{ desc.observacion }}</td>
                  </tr>
                  <tr v-if="descuentos.length === 0">
                    <td colspan="6" class="text-center">Sin descuentos</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagosMultFrm',
  data() {
    return {
      form: {
        fecha: '',
        recaud: '',
        caja: '',
        folio: '',
        nombre: '',
        num_acta: ''
      },
      pagos: [],
      showResults: false,
      detalle: null,
      descuentos: []
    };
  },
  methods: {
    async buscarPagos() {
      this.showResults = false;
      this.pagos = [];
      this.detalle = null;
      this.descuentos = [];
      const params = { ...this.form };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: 'pagosmultfrm.searchPagosMultas',
          params
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.pagos = json.eResponse.data;
      } else {
        alert(json.eResponse.message || 'Error en la búsqueda');
      }
      this.showResults = true;
    },
    async verDetalle(pago) {
      // Obtener detalle de multa
      const multaRes = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: 'pagosmultfrm.getMultaDetalle',
          params: { id_multa: pago.cvecuenta }
        })
      });
      const multaJson = await multaRes.json();
      if (multaJson.eResponse.success && multaJson.eResponse.data.length > 0) {
        this.detalle = multaJson.eResponse.data[0];
        // Obtener descuentos
        const descRes = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'pagosmultfrm.getDescuentos',
            params: { id_multa: this.detalle.id_multa }
          })
        });
        const descJson = await descRes.json();
        this.descuentos = descJson.eResponse.success ? descJson.eResponse.data : [];
      } else {
        alert('No se encontró el detalle de la multa');
      }
    },
    resetBusqueda() {
      this.showResults = false;
      this.pagos = [];
      this.detalle = null;
      this.descuentos = [];
      this.form = {
        fecha: '',
        recaud: '',
        caja: '',
        folio: '',
        nombre: '',
        num_acta: ''
      };
    }
  },
  filters: {
    currency(value) {
      if (typeof value !== 'number') return value;
      return '$' + value.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.pagosmultfrm-page {
  max-width: 1200px;
  margin: 0 auto;
}
pre {
  background: #f8f9fa;
  padding: 8px;
  border-radius: 4px;
}
</style>
