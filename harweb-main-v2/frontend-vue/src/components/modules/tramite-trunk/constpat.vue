<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Transmisiones Patrimoniales</li>
      </ol>
    </nav>
    <h2 class="mb-4">Consulta de Transmisiones Patrimoniales</h2>
    <div class="card mb-4">
      <div class="card-header">Consulta por Folio</div>
      <div class="card-body">
        <form @submit.prevent="consultarPorFolio">
          <div class="form-row align-items-end">
            <div class="col-auto">
              <label for="folio">Inserta el Folio:</label>
              <input type="number" v-model.number="folio" id="folio" class="form-control" min="1" required />
            </div>
            <div class="col-auto">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
        <div v-if="folioResult.length" class="mt-3">
          <h5>Resultados</h5>
          <div class="table-responsive">
            <table class="table table-sm table-bordered">
              <thead>
                <tr>
                  <th>Folio</th>
                  <th>Bimestre</th>
                  <th>Año de Efectos</th>
                  <th>Comprobante</th>
                  <th>Año</th>
                  <th>Status</th>
                  <th>Escrituras</th>
                  <th>Otorgamiento</th>
                  <th>Firma</th>
                  <th>Adjudicación</th>
                  <th>Valor de la Operación</th>
                  <th>Exenta</th>
                  <th>Fecha Entrada</th>
                  <th>Fecha de Trámite</th>
                  <th>Capturista</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in folioResult" :key="row.folio">
                  <td>{{ row.folio }}</td>
                  <td>{{ row.bimefec }}</td>
                  <td>{{ row.axoefec }}</td>
                  <td>{{ row.nocomp }}</td>
                  <td>{{ row.axocomp }}</td>
                  <td>{{ row.nstatus }}</td>
                  <td>{{ row.noescrituras }}</td>
                  <td>{{ row.fechaotorg }}</td>
                  <td>{{ row.fechafirma }}</td>
                  <td>{{ row.fechaadjudicacion }}</td>
                  <td>{{ row.valortransm }}</td>
                  <td>{{ row.exento }}</td>
                  <td>{{ row.feccap }}</td>
                  <td>{{ row.fectram }}</td>
                  <td>{{ row.capturista }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div v-if="folioError" class="alert alert-danger mt-2">{{ folioError }}</div>
      </div>
    </div>

    <div class="card mb-4">
      <div class="card-header">Consulta de Transmisiones Pagadas por Rango de Fechas</div>
      <div class="card-body">
        <form @submit.prevent="consultarPorFechas">
          <div class="form-row align-items-end">
            <div class="col-auto">
              <label for="desde">DE:</label>
              <input type="date" v-model="desde" id="desde" class="form-control" required />
            </div>
            <div class="col-auto">
              <label for="hasta">A:</label>
              <input type="date" v-model="hasta" id="hasta" class="form-control" required />
            </div>
            <div class="col-auto">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
            <div class="col-auto">
              <div class="form-check">
                <input class="form-check-input" type="radio" id="folioxfolio" value="folioxfolio" v-model="consultaTipo" checked />
                <label class="form-check-label" for="folioxfolio">Folio x Folio</label>
              </div>
              <div class="form-check">
                <input class="form-check-input" type="radio" id="totalesxdia" value="totalesxdia" v-model="consultaTipo" />
                <label class="form-check-label" for="totalesxdia">Totales por Día</label>
              </div>
            </div>
          </div>
        </form>
        <div v-if="fechasResult.length" class="mt-3">
          <h5>Resultados</h5>
          <div class="table-responsive">
            <table class="table table-sm table-bordered" v-if="consultaTipo==='folioxfolio'">
              <thead>
                <tr>
                  <th>Folio</th>
                  <th>Fecha de Pago</th>
                  <th>Escrituras</th>
                  <th>No. Notario</th>
                  <th>Notario Nombre</th>
                  <th>Paterno</th>
                  <th>Materno</th>
                  <th>Rec</th>
                  <th>Tipo</th>
                  <th>Cuenta</th>
                  <th>Comprobante</th>
                  <th>Año Comp</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in fechasResult" :key="row.folio">
                  <td>{{ row.folio }}</td>
                  <td>{{ row.fecha }}</td>
                  <td>{{ row.noescrituras }}</td>
                  <td>{{ row.notaria }}</td>
                  <td>{{ row.nombres }}</td>
                  <td>{{ row.paterno }}</td>
                  <td>{{ row.materno }}</td>
                  <td>{{ row.recaud }}</td>
                  <td>{{ row.urbrus }}</td>
                  <td>{{ row.cuenta }}</td>
                  <td>{{ row.nocomp }}</td>
                  <td>{{ row.axocomp }}</td>
                  <td>{{ row.status }}</td>
                </tr>
              </tbody>
            </table>
            <table class="table table-sm table-bordered" v-else>
              <thead>
                <tr>
                  <th>Fecha</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in fechasResult" :key="row.fecha">
                  <td>{{ row.fecha }}</td>
                  <td>{{ row.total }}</td>
                </tr>
              </tbody>
            </table>
            <div class="mt-2">
              <strong>Total de folios: </strong>{{ totalFolios }}
            </div>
          </div>
        </div>
        <div v-if="fechasError" class="alert alert-danger mt-2">{{ fechasError }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaTransmisionesPatrimoniales',
  data() {
    return {
      folio: '',
      folioResult: [],
      folioError: '',
      desde: '',
      hasta: '',
      fechasResult: [],
      fechasError: '',
      consultaTipo: 'folioxfolio',
      totalFolios: 0
    };
  },
  methods: {
    async consultarPorFolio() {
      this.folioError = '';
      this.folioResult = [];
      if (!this.folio) {
        this.folioError = 'Debe ingresar un folio válido.';
        return;
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'consultarTransmisionPorFolio',
            params: { folio: this.folio }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.folioResult = data.data;
        } else {
          this.folioError = data.error || 'Error en la consulta.';
        }
      } catch (e) {
        this.folioError = 'Error de red o servidor.';
      }
    },
    async consultarPorFechas() {
      this.fechasError = '';
      this.fechasResult = [];
      this.totalFolios = 0;
      if (!this.desde || !this.hasta) {
        this.fechasError = 'Debe ingresar ambas fechas.';
        return;
      }
      try {
        if (this.consultaTipo === 'folioxfolio') {
          // Consulta detallada
          const [res, totalRes] = await Promise.all([
            fetch('/api/execute', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                eRequest: 'consultarTransmisionesPorFechas',
                params: { desde: this.desde, hasta: this.hasta }
              })
            }),
            fetch('/api/execute', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                eRequest: 'contarFoliosPorFechas',
                params: { desde: this.desde, hasta: this.hasta }
              })
            })
          ]);
          const data = await res.json();
          const totalData = await totalRes.json();
          if (data.success) {
            this.fechasResult = data.data;
            this.totalFolios = totalData.data ? totalData.data.total : 0;
          } else {
            this.fechasError = data.error || 'Error en la consulta.';
          }
        } else {
          // Consulta totales por día
          const [res, totalRes] = await Promise.all([
            fetch('/api/execute', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                eRequest: 'consultarTransmisionesTotalesPorFecha',
                params: { desde: this.desde, hasta: this.hasta }
              })
            }),
            fetch('/api/execute', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                eRequest: 'contarFoliosPorFechas',
                params: { desde: this.desde, hasta: this.hasta }
              })
            })
          ]);
          const data = await res.json();
          const totalData = await totalRes.json();
          if (data.success) {
            this.fechasResult = data.data;
            this.totalFolios = totalData.data ? totalData.data.total : 0;
          } else {
            this.fechasError = data.error || 'Error en la consulta.';
          }
        }
      } catch (e) {
        this.fechasError = 'Error de red o servidor.';
      }
    }
  }
};
</script>

<style scoped>
.table-responsive {
  max-height: 400px;
  overflow-y: auto;
}
</style>
