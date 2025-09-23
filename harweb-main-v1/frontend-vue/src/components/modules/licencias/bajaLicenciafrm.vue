<template>
  <div class="baja-licencia-page">
    <h1>Baja de Licencia</h1>
    <form @submit.prevent="buscarLicencia">
      <div class="form-group">
        <label for="licencia">No. de licencia:</label>
        <input v-model="form.licencia" id="licencia" type="text" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="licencia">
      <div class="licencia-info">
        <h2>Datos de la Licencia</h2>
        <p><strong>Recaudadora:</strong> {{ licencia.recaud }}</p>
        <p><strong>Giro:</strong> {{ giro.descripcion }}</p>
        <p><strong>Actividad:</strong> {{ licencia.actividad }}</p>
        <p><strong>Propietario:</strong> {{ licencia.primer_ap }} {{ licencia.segundo_ap }} {{ licencia.propietario }}</p>
        <p><strong>Ubicación:</strong> {{ licencia.ubicacion }} No. ext: {{ licencia.numext_ubic }} Letra ext: {{ licencia.letraext_ubic }} No. int: {{ licencia.numint_ubic }} Letra int: {{ licencia.letraint_ubic }}</p>
        <p><strong>Sup. construida:</strong> {{ licencia.sup_construida }}</p>
        <p><strong>Sup. autorizada:</strong> {{ licencia.sup_autorizada }}</p>
        <p><strong>Num. cajones:</strong> {{ licencia.num_cajones }}</p>
        <p><strong>Num. empleados:</strong> {{ licencia.num_empleados }}</p>
      </div>
      <div v-if="adeudos && adeudos.total > 0 && !bajaError">
        <div class="alert alert-warning">
          <strong>¡Precaución!</strong> La licencia tiene adeudos.
        </div>
        <div class="adeudos-info">
          <p><strong>Derechos:</strong> {{ adeudos.adeudos[0]?.derechos || 0 }}</p>
          <p><strong>Anuncios:</strong> {{ adeudos.adeudos[0]?.anuncios || 0 }}</p>
          <p><strong>Recargos:</strong> {{ adeudos.adeudos[0]?.recargos || 0 }}</p>
          <p><strong>Gastos:</strong> {{ adeudos.adeudos[0]?.gastos || 0 }}</p>
          <p><strong>Multas:</strong> {{ adeudos.adeudos[0]?.multas || 0 }}</p>
          <p><strong>Formas:</strong> {{ adeudos.adeudos[0]?.formas || 0 }}</p>
          <p><strong>Total:</strong> {{ adeudos.total }}</p>
        </div>
      </div>
      <div v-if="anuncios && anuncios.length > 0">
        <h3>Anuncios ligados a esta licencia</h3>
        <table class="table">
          <thead>
            <tr>
              <th>No. anuncio</th>
              <th>F. otorgamiento</th>
              <th>Medidas</th>
              <th>Área</th>
              <th>Ubicación</th>
              <th>No. ext.</th>
              <th>Letra ext.</th>
              <th>No. int.</th>
              <th>Letra int.</th>
              <th>Colonia</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="an in anuncios" :key="an.id_anuncio">
              <td>{{ an.anuncio }}</td>
              <td>{{ an.fecha_otorgamiento }}</td>
              <td>{{ an.medidas1 }}</td>
              <td>{{ an.area_anuncio }}</td>
              <td>{{ an.ubicacion }}</td>
              <td>{{ an.numext_ubic }}</td>
              <td>{{ an.letraext_ubic }}</td>
              <td>{{ an.numint_ubic }}</td>
              <td>{{ an.letraint_ubic }}</td>
              <td>{{ an.colonia_ubic }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <form @submit.prevent="confirmarBaja">
        <div class="form-group">
          <label for="motivo">Motivo de la baja:</label>
          <input v-model="form.motivo" id="motivo" type="text" required />
        </div>
        <div class="form-group">
          <input type="checkbox" v-model="bajaError" id="bajaError" />
          <label for="bajaError">Baja por error</label>
        </div>
        <div v-if="!bajaError" class="form-group">
          <label for="anio">Año:</label>
          <input v-model="form.anio" id="anio" type="number" required />
          <label for="folio">Folio:</label>
          <input v-model="form.folio" id="folio" type="number" required />
        </div>
        <button type="submit" :disabled="bajaEnProceso">Dar de baja</button>
      </form>
      <div v-if="mensaje" :class="{'alert': true, 'alert-success': exito, 'alert-danger': !exito}">
        {{ mensaje }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BajaLicenciaPage',
  data() {
    return {
      form: {
        licencia: '',
        motivo: '',
        anio: '',
        folio: ''
      },
      licencia: null,
      giro: {},
      adeudos: null,
      anuncios: [],
      bajaError: false,
      bajaEnProceso: false,
      mensaje: '',
      exito: false
    };
  },
  methods: {
    async buscarLicencia() {
      this.mensaje = '';
      this.exito = false;
      this.licencia = null;
      this.giro = {};
      this.adeudos = null;
      this.anuncios = [];
      // Buscar licencia
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'buscarLicencia', params: { licencia: this.form.licencia } })
      });
      const data = await resp.json();
      if (!data.success) {
        this.mensaje = data.message || 'Licencia no encontrada';
        return;
      }
      this.licencia = data.licencia;
      this.giro = data.giro;
      // Adeudos
      const resp2 = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'verificarAdeudos', params: { id_licencia: this.licencia.id_licencia } })
      });
      this.adeudos = await resp2.json();
      // Anuncios
      const resp3 = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'listarAnunciosLigados', params: { id_licencia: this.licencia.id_licencia } })
      });
      const data3 = await resp3.json();
      this.anuncios = data3.anuncios || [];
    },
    async confirmarBaja() {
      this.bajaEnProceso = true;
      this.mensaje = '';
      this.exito = false;
      // Validaciones
      if (!this.form.motivo) {
        this.mensaje = 'Debe indicar el motivo de la baja';
        this.bajaEnProceso = false;
        return;
      }
      if (!this.bajaError && (!this.form.anio || !this.form.folio)) {
        this.mensaje = 'Debe indicar año y folio';
        this.bajaEnProceso = false;
        return;
      }
      // Confirmar baja
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'bajaLicencia',
          params: {
            id_licencia: this.licencia.id_licencia,
            motivo: this.form.motivo,
            anio: this.bajaError ? null : this.form.anio,
            folio: this.bajaError ? null : this.form.folio,
            baja_error: this.bajaError
          }
        })
      });
      const data = await resp.json();
      this.bajaEnProceso = false;
      this.mensaje = data.message;
      this.exito = data.success;
      if (data.success) {
        this.licencia = null;
        this.giro = {};
        this.adeudos = null;
        this.anuncios = [];
        this.form.motivo = '';
        this.form.anio = '';
        this.form.folio = '';
      }
    }
  }
};
</script>

<style scoped>
.baja-licencia-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.form-group {
  margin-bottom: 1rem;
}
.alert {
  padding: 1rem;
  margin-top: 1rem;
}
.alert-success {
  background: #e6ffe6;
  color: #2d662d;
}
.alert-danger {
  background: #ffe6e6;
  color: #662d2d;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
</style>
