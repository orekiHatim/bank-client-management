--PARTIE 1
use banque
create table clients(num_client int primary key identity, nom_client varchar(15), adresse_client varchar(30), mot_de_passe
					varchar(10), date_derniere_consultation date, secteur numeric)

create table comptes(num_compte int primary key identity, libelle_compte varchar(20), date_commande_chequier date,
					solde_compte numeric(10,2), decouvert_autorise numeric(8,2), num_client int, type_compte 
					varchar(3))

create table operations(num_operation int primary key identity, libelle_operation varchar(20), montant_operation 
						numeric(8,2), date_opertaion date, num_compte int, type_operation varchar(10))

create table type_compte(type_compte varchar(3) primary key, intitule_compte varchar(20))

create table type_operation(type_operation varchar(10) primary key)

alter table comptes add foreign key (num_client) references clients(num_client)

alter table comptes add foreign key (type_compte) references type_compte(type_compte)

alter table operations add foreign key (num_compte) references comptes(num_compte)

alter table operations add foreign key (type_operation) references type_operation(type_operation)

insert into clients values('HATIM', 'ADRESSE HATIM AB 12', 'HATIM2018', '11-18-2022', 14)

insert into type_compte values('MC', 'MASTERCARD'),('EC', 'E-CARD')

insert into type_operation values('VIREMENT'),('RETRAIT')

insert into comptes values('COMPTE1', GETDATE(), 4000, 1000, 2, 'MC')

insert into operations values('OP1', 1200, GETDATE(), 2, 'RETRAIT')

select * from operations


--PARTIE 2

create procedure ajout_client(@nom varchar(15), @adresse varchar(30), @password varchar(10))
as
begin
	insert into clients values(@nom, @adresse, @password, GETDATE(), 14)
end

--test ajou_client
exec ajout_client 'MODRIC', 'MODRIC ADRESSE 12 D 4', 'MODRIC123'

select * from clients

--creation ajout_compte
create or alter procedure ajout_compte(@libelle varchar(20), @solde numeric(10,2), @decouvert numeric(8,2),
									@num_client int, @type varchar(3), @out int output )
as
begin
	--check si le client exist
	if ((select count(num_client) from clients where num_client =  @num_client) = 1)
	begin	
			--check si le type de compte est valide
			if ((select count(type_compte) from type_compte where type_compte = UPPER(@type) ) = 1)
			begin
				--ajout de compte
				insert into comptes values(@libelle, GETDATE(), @solde, @decouvert, @num_client, @type)
				select @out=1
			end
			ELSE
			begin
				select @out=4
			end
	end
	else
	begin
		select @out=2
	end
	
end

--@out = 2 => un erreur au niveau de num_client (il n'ya pas d'un client avec ce num)
--@out = 4 => erreur au niveau de type de compte, (ce type n'existe pas)
--@out = 1 => ajout de compte avec succés

--test ajout_compte
declare @out1 int
exec ajout_compte 'COMPTE 2', 4000,1200,3, 'MC', @out1 output
select @out1

select * from comptes


--creation de virement
create or alter procedure virement(@num_compte1 int, @num_compte2 int, @montant numeric(10,2), @out12 varchar(1) output)
as
begin
	--check si les comptes exist
	if ((select count(num_compte) from comptes where num_compte = @num_compte1 or num_compte = @num_compte2) = 2)
	begin
		--check si le montant est >= solde + decouvert
		if ((select solde_compte + decouvert_autorise from comptes where num_compte = @num_compte1) >= @montant)
		begin
			update comptes set solde_compte = solde_compte + @montant where num_compte = @num_compte2
			declare @solde numeric(10,2)
			set @solde = (select solde_compte from comptes where num_compte = @num_compte1)
			if ( @solde >= @montant)
			begin
				update comptes set solde_compte = solde_compte - @montant where num_compte = @num_compte1
			end
			else
			begin
				set @solde = @solde - @montant
				--set solde a 0 et soustracter le reste du decouvert
				update comptes set solde_compte = 0, decouvert_autorise = decouvert_autorise + @solde where
				num_compte = @num_compte1
				--print 'virement a ete effectué'
				set @out12 = '1'
			end
		end
		else
		begin
			--print 'montant > solde + decouvert'
			set @out12 = '2'
		end
	end
	else
	begin
		--print 'no such num_compte'
		set @out12 = '3'
	end
end

--test virement procedure

select * from comptes


declare @a16 varchar(1)
exec virement 3,4,200, @a16 output
select @a16

select * from comptes


--creation de ajout_operation
create or alter procedure ajout_operation(@libelle varchar(20), @montant numeric(8,2), @num_compte1 int, 
									@num_compte2 int, @type varchar(10), @out int output)
as
begin
	if (UPPER(@type) = 'VIREMENT')
	begin
		declare @isValid int
		exec virement @num_compte1,@num_compte2,@montant, @isValid output
		if (@isValid = 1)
		begin
			--insert les operation apres la validation de virement avec isValide
			--montant * -1 signifie que vous avez une reduction de solde
			insert into operations values(@libelle, @montant * -1, GETDATE(), @num_compte1, 'VIREMENT')
			insert into operations values(@libelle, @montant, GETDATE(), @num_compte2, 'VIREMENT')
			set @out = 1
		end
		else
		begin
			--print 'error est survenue'
			set @out = @isValid 
		end
	end
	else if (UPPER(@type) = 'RETRAIT')
	begin
		--tant que l'operation est retrait, on prendre en consideration que num_compte1
		if ((select count(num_compte) from comptes where num_compte = @num_compte1 ) = 1)
		begin
			if ((select solde_compte + decouvert_autorise from comptes where num_compte = @num_compte1) >= @montant)
			begin
				insert into operations values(@libelle, @montant * -1, GETDATE(), @num_compte1, 'RETRAIT')
				declare @solde numeric(10,2)
				set @solde = (select solde_compte from comptes where num_compte = @num_compte1)
				if ( @solde >= @montant)
				begin
					update comptes set solde_compte = solde_compte - @montant where num_compte = @num_compte1
				end
				else
				begin
					set @solde = @solde - @montant
					update comptes set solde_compte = 0, decouvert_autorise = decouvert_autorise + @solde where
					num_compte = @num_compte1
					
					--print 'retaraite a ete effectué'
					set @out = 1
				end
			end
			else
			begin
				--print 'montant > solde + decouvert'
				set @out = 2
			end
		end
		else
		begin
			--print 'no such num_compte'
			set @out = 3
		end
	end
	else
	begin
		--print 'no such type'
		set @out = 4
	end
end

--teste ajout_operation
declare @out14 int
exec ajout_operation 'OP5',100,4,4,'retrait',@out14 output
print @out14

select * from comptes

select * from operations

select * from clients


create or alter function releve_compte(@num_compte int)
returns @tab table(libelle_compte varchar(20), solde_compte numeric(10,2), decouvert_autorise numeric(8,2),
							num_client int, intitule_compte varchar(20), nom_client varchar(15), adresse_client varchar(30),
							mot_de_passe varchar(10), date_derniere_consultation date)
as
begin
	if ((select count(num_compte) from comptes where num_compte = @num_compte) = 1)
	begin

		insert into @tab select cm.libelle_compte , cm.solde_compte, cm.decouvert_autorise, cm.num_client, tc.intitule_compte,
					c.nom_client, c.adresse_client, c.mot_de_passe, c.date_derniere_consultation 
					from comptes cm inner join clients c on cm.num_client = c.num_client 
					inner join type_compte tc on tc.type_compte = cm.type_compte where cm.num_compte = @num_compte 

	end
	return
end

select * from releve_compte(4)

--
create or alter function releve_operations(@num_compte int)
returns @tab2 table (libelle_operation varchar(20), montant_operation numeric(8,2), date_operation date,
					type_operation varchar(10))
as
begin
	if ((select count(num_compte) from operations where num_compte = @num_compte ) = 1)
	begin
		declare @query cursor
		declare @libelle varchar(20)
		declare @montant numeric(8,2)
		declare @date date
		declare @type varchar(10)
		set @query = cursor for (select libelle_operation, montant_operation, date_opertaion,
						type_operation from operations where num_compte = @num_compte)
		
		open @query
		fetch next from @query into @libelle, @montant, @date, @type
		while @@FETCH_STATUS = 0
		begin
				insert into @tab2 values(@libelle, @montant, @date, @type)
				fetch next from @query into @libelle, @montant, @date, @type
		end
		close @query
		deallocate @query
	end
	return
end

select * from releve_operations(4)

select * from operations




select * from comptes


